<!-- dx-header -->
# Get Sites-only VCF 

## What does this app do?

This app generates a 'sites-only' file from VCF file(s) (`*.vcf.gz`).

## What data are required for this app to run?

This app requires VCF file(s) (`*.vcf.gz`) as an input. 

## What does this app output?

This app outputs a site only VCF file(s) (`*.vcf.gz`) along with this index file. This output VCF file (`*.vcf.gz`) would contain the first eight columns of the original VCF file.

## How does this app work?

This app uses the cut command to get a sites-only vcf (1st 8 columns) of the VCF file (`*.vcf.gz`). 