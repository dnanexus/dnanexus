#!/bin/bash
# vcf_qc 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://wiki.dnanexus.com/Developer-Portal for tutorials on how
# to modify this file.

set -x
set -o pipefail

main() {

	echo "Value of query_str: '$query_str'"
    echo "Value of vcf_fn: '$vcf_fn'"
    echo "Value of vcfidx_fn: '$vcfidx_fn'"

	# Sanity check - make sure vcf + vcfidx have same # of elements
	if test "${#vcfidx_fn[@]}" -ne "${#vcf_fn[@]}"; then
		dx-jobutil-report-error "ERROR: Number of VCFs and VCF indexes do NOT match!"
	fi

	# first, we need to match up the VCF and tabix index files
	# To do that, we'll get files of filename -> dxfile ID
	VCF_LIST=$(mktemp)
	for i in "${!vcf_fn[@]}"; do	
		dx describe --json "${vcf_fn[$i]}" | jq -r ".name,.id" | tr '\n' '\t' | sed 's/\t$/\n/' >> $VCF_LIST
	done
	
	VCFIDX_LIST=$(mktemp)
	for i in "${!vcfidx_fn[@]}"; do	
		dx describe --json "${vcfidx_fn[$i]}" | jq -r ".name,.id" | tr '\n' '\t' | sed -e 's/\t$/\n/' -e 's/\.tbi\t/\t/' >> $VCFIDX_LIST
	done
	
	# Now, get the prefix (strip off any .tbi) and join them
	JOINT_LIST=$(mktemp)
	join -t$'\t' -j1 <(sort -k1,1 $VCF_LIST) <(sort -k1,1 $VCFIDX_LIST) > $JOINT_LIST
		
	# Ensure that we still have the same number of files; throw an error if not
	if test $(cat $JOINT_LIST | wc -l) -ne "${#vcf_fn[@]}"; then
		dx-jobutil-report-error "ERROR: VCF files and indexes do not match!"
	fi
	
	# and loop through the file, submitting sub-jobs
	CAT_ARGS=""
	while read VCF_LINE; do
		VCF_DXFN=$(echo "$VCF_LINE" | cut -f2)
		VCFIDX_DXFN=$(echo "$VCF_LINE" | cut -f3)		
	
		SUBJOB=$(dx-jobutil-new-job run_query -ivcf_fn:file="$VCF_DXFN" -ivcfidx_fn:file="$VCFIDX_DXFN" -iquery_str:string=$query_str)
		CAT_ARGS="$CAT_ARGS -iquery_in:array:file=$SUBJOB:query_out"
		
		if test "$cat_results" = "false"; then
			# for each subjob, add the output to our array
    		dx-jobutil-add-output query_out --array "$SUBJOB:query_out" --class=jobref
    	fi
		
	done < $JOINT_LIST
	
	if test "$cat_results" = "true"; then
		CATJOB=$(dx-jobutil-new-job cat_results $CAT_ARGS -iprefix:string=$prefix)
		dx-jobutil-add-output query_out --array "$CATJOB:query_out" --class=jobref
	fi
	
}


run_query() {

    echo "Value of vcf_fn: '$vcf_fn'"
    echo "Value of vcfidx_fn: '$vcfidx_fn'"
	echo "Value of query_str: '$query_str'"

	# The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".

    dx download "$vcf_fn" -o input.vcf.gz
    dx download "$vcfidx_fn" -o input.vcf.gz.tbi
    
	OUT_DIR=$(mktemp -d)
	PREFIX=$(dx describe --name "$vcf_fn" | sed 's/\.vcf.\(gz\)*$//')

	#ls -alh

	# TODO: parallelize smartly using -r chr:from-to and output accordingly
	bcftools query input.vcf.gz -f "$query_str"  -H | sed -e'1 s/\[[0-9]*\]//g' -e '1 s/  *//g' |  bgzip -c > $OUT_DIR/$PREFIX.query.gz
	
	#cat output

	query_out=$(dx upload "$OUT_DIR/$PREFIX.query.gz" --brief)

    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.

    dx-jobutil-add-output query_out "$query_out" --class=file
}

cat_results() {

	echo "Value of query_in: '$query_in'"
	echo "Value of prefix: '$prefix'"
	
	CAT_ARGS=""
	for i in "${!query_in[@]}"; do
		CAT_ARGS="$CAT_ARGS -V $(dx describe --json "${query_in[$i]}" | jq -r .id)"
	done
	
	# get the dict
	WKDIR=$(mktemp -d)
	cd $WKDIR
	
	OUTDIR=$(mktemp -d)
	
	dx download "$DX_RESOURCES_ID:/GATK/resources/human_g1k_v37_decoy.dict" -o ref.dict
	
	cat_vcf.py -D ref.dict $CAT_ARGS -o $OUTDIR/$prefix.query.gz
	query_out=$(dx upload $OUTDIR/$prefix.query.gz --brief)
	dx-jobutil-add-output query_out $query_out
}
	
