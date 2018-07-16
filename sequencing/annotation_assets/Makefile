all:
ifneq ("$(wildcard $(/sources/vep_37.tar.gz))", "")
  echo "VEP conversion not yet implemented"
endif
ifneq ("$(wildcard $(/sources/vep_38.tar.gz))", "")
  echo "VEP conversion not yet implemented"
endif
ifneq ("$(wildcard $(/sources/dbnsfp_37.zip))", "")
  echo "dbNSFP conversion not yet implemented"
endif
ifneq ("$(wildcard $(/sources/dbnsfp_38.zip))", "")
  echo "dbNSFP conversion not yet implemented"
endif
ifneq ("$(wildcard $(/sources/hgmd_37.txt.gz))", "")
  mkdir -p /hgmd
  python /scripts/reformatHGMD.py /sources/hgmd_37.vcf.gz | bgzip -c > /hgmd/hgmd_37.vcf.gz
  tabix -p vcf -f /hgmd/hgmd_37.vcf.gz
endif
ifneq ("$(wildcard $(/sources/hgmd_38.txt.gz))", "")
  mkdir -p /hgmd
  python /scripts/reformatHGMD.py /sources/hgmd_38.vcf.gz | bgzip -c > /hgmd/hgmd_38.vcf.gz
  tabix -p vcf -f /hgmd/hgmd_38.vcf.gz
endif
ifneq ("$(wildcard $(/sources/clinvar.txt.gz))", "")
  mkdir -p /clinvar
  python ClinVar_tsvTOvcf.py /sources/clinvar.txt.gz
  vcf-sort -c /sources/clinvar_b37.vcf | bgzip -c > /clinvar/clinvar_b37.vcf.gz
  tabix -p vcf -f /clinvar/clinvar_b37.vcf.gz
  vcf-sort -c /sources/clinvar_b38.vcf | bgzip -c > /clinvar/clinvar_b38.vcf.gz
  tabix -p vcf -f /clinvar/clinvar_b38.vcf.gz
else
  ifneq ("$(wildcard $(/sources/clinvar_37.txt.gz))", "")
    mkdir -p /clinvar
    python ClinVar_tsvTOvcf.py clinvar_37.txt.gz
    vcf-sort -c /sources/clinvar_b37.vcf | bgzip -c > /clinvar/clinvar_b37.vcf.gz
    tabix -p vcf -f /clinvar/clinvar_b37.vcf.gz
  endif
  ifneq ("$(wildcard $(/sources/clinvar_38.txt.gz))", "")
    mkdir -p /clinvar
    python ClinVar_tsvTOvcf.py clinvar_38.txt.gz
    vcf-sort -c /sources/clinvar_b38.vcf | bgzip -c > /clinvar/clinvar_b38.vcf.gz
    tabix -p vcf -f /clinvar/clinvar_b38.vcf.gz
  endif
endif
