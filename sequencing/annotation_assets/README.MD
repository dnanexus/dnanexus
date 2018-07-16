# Annotation Assets

To use annotation apps such as vcf_annotate and clinical_annotator, you need to provide database files in VCF format. Given the database input files, this project will convert the databases to VCF format and build a DNAnexus asset bundle.

## Annotation Sources

Because these databases are large, and because some require licenses, you need to first manually download the database files into the ./resources/sources directory. The build process will execute the necessary scripts (found in ./resources/scripts) to convert those files into VCF format. The source (i.e. non-VCF) databases will not be included in the asset bundle.

Please make sure to download the correct version of the database for the genome build that you are using (37 or 38). If you want your asset bundle to include VCFs for both genome builds, simply download both versions of the source databases.

You only need to download the databases you intend to use. The build script will ignore any databases for which the database files are not found.

The source (non-VCF) databases will not be included in the asset bundle. The database files are *not* removed automatically; you need to delete them if you no longer want them after you create the asset bundle:

```
rm -rf sources/* vep dbnsfp hgmd clinvar  
```

### VEP

Database that aggregates many different annotation sources. Replace <REL> with the desired release and <37|38> with the desired genome build.

```
wget -O sources/vep_<37|38>.tar.gz \
  ftp://ftp.ensembl.org/pub/release-<REL>/variation/VEP/homo_sapiens_merged_vep_<REL>_GRCh<37|38>.tar.gz
```

TODO: get the conversion script from Ritchie lab.

### dbNSFP

Dabase of functional prediction scores for non-synonymous SNVs. Combines scores from ~20 prediction algorithms into a single datbase. The database is free for use, but different versions are available for academic and commerical users (the commercial version does not include scores from algorithms that are not licensed for commercial use). Download the appropriate version from the [dbNSFP website](https://sites.google.com/site/jpopgen/dbNSFP). Note that version 2.x releases are based on build 37 coordnates and 3.x releases are based on build 38 coordinates.

The dbNSFP file must be placed at `sources/dbnsfp_<37|38>.zip`.

TODO: get the conversion script from Ritchie lab.

### HGMD

Database of disease-associated human gene mutations. HGMD license is free for academic use (registration required); commercial users must pay for a license. See the [HGMD website](http://www.hgmd.cf.ac.uk/ac/index.php) for details.

The HGMD file must be placed at `sources/hgmd_<37|38>.txt.gz`.

### ClinVar

Database of clinically relevant variants. Recent versions contain both build 37 and 38 coordinates. If you name the file with the build version, the conversion script will only generate a VCF file for that version, otherwise it will generate both b37 and b38 VCFs.

```
wget -O sources/clinvar[_<37|38>].txt.gz \
  ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/variant_summary.txt.gz
``` 

## Build the AssetBundle

```
dx build_asset .
```
