<!-- dx-header -->
# vcf_query (DNAnexus Platform App)

## What does this app do?
Calls "bcftools query" to extract annotations from the VCF file (`*.vcf.gz`).

## What data are required for this app to run?

This app requires the VCF file (`*.vcf.gz`) along with its index file (`*.gz.tbi`)as an input. Also, as an required input, it takes in a string input consisting of the query that would be performed on the VCF file. This can contain fields of the VCF file in a tab delimited format. For example, the default query the app will perform is "%CHROM\\t%POS\\t%ID\\t%REF\\t%ALT\\t%QUAL\\t%INFO/QD\\t%INFO/AN\\t%INFO/AC[\\t%GT]\\n"

Additonally, the app has an option to concentate the results into a single file. 

## What does this applet output?

The applet outputs the annotations from the VCF file as a (`*.query.gz`) file. 