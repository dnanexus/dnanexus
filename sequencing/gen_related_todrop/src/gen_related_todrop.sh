#!/bin/bash
# gen_related_todrop 0.0.1
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
install_bioconductor() {
    R --quiet -e 'source("http://bioconductor.org/biocLite.R"); biocLite(repos="http://cran.rstudio.com/")'
}

install_gsalib_cran() {
    R --quiet -e 'install.packages("optparse", repos="http://cran.rstudio.com/")'
   # wget -q http://cran.rstudio.com/src/contrib/Archive/plyr/plyr_1.8.1.tar.gz
   # R CMD INSTALL --quiet plyr_1.8.1.tar.gz
    R --quiet -e 'install.packages("reshape2", repos="http://cran.rstudio.com/")'
    R --quiet -e 'install.packages("parallel", repos="http://cran.rstudio.com/")'
    R --quiet -e 'install.packages("doMC", repos="http://cran.rstudio.com/")'
    R --quiet -e 'install.packages("foreach", repos="http://cran.rstudio.com/")'
}

main() {

    echo "Value of genome: '$genome'"
    echo "Value of id1_col: '$id1_col'"
    echo "Value of id2_col: '$id2_col'"
    echo "Value of pihat_col: '$pihat_col'"

    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".

    WKDIR=$(mktemp -d)
    cd $WKDIR

	ext=$(dx describe --name "$genome" | sed 's/.*\.//')
	FN=genome.$ext

    #dx download "$genome" -o $FN
    
    cat_cmd="cat"
    if test "$ext" == "gz"; then
    	cat_cmd="zcat"
    fi
    
    CMD_ARGS=""
    if test "$exact" = "true"; then
    	CMD_ARGS="$CMD_ARGS --exact"
    fi
    
    if test "$drop_before" = "true"; then
    	CMD_ARGS="$CMD_ARGS --drop-before"
    fi
    
	if test "$pref"; then
		dx download "$pref" -o pref
		CMD_ARGS="$CMD_ARGS --order=pref"
	fi
	
	AWK_CMD="{print \$$id1_col "\"\\t\"" \$$id2_col }"
	if test "$pihat_col" -ne 0; then
		AWK_CMD="{if(\$$pihat_col < $thresh)$AWK_CMD }"
	fi
	
	dx cat "$genome" | $cat_cmd | awk "$AWK_CMD" > related_pair
	
	OUTDIR=$(mktemp -d)
	drop_related.R --pairs related_pair --out $OUTDIR/$prefix.todrop $CMD_ARGS

    relateds=$(dx upload $OUTDIR/$prefix.todrop --brief)
    dx-jobutil-add-output relateds "$relateds" --class=file
}


