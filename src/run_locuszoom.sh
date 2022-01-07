#!/bin/bash

usage() { echo "Usage: $0 {-a <ancestry> (AFR/AMR/EUR/TRANS)} {-f <path to config file>}"; exit 1; }

# get arguments
while getopts a:f: flag
do
  case "${flag}" in
    a) ANCESTRY=${OPTARG};;
    f) CONFIG_FILE=${OPTARG};;
    *) usage;;
  esac
done
echo $ANCESTRY $CONFIG_FILE

# check arguments exist
if [ -z "${ANCESTRY}" ] || [ -z "${CONFIG_FILE}" ]; then
  usage
fi

# define ancestry-specific variables
if [[ $ANCESTRY == "AFR" ]]; then
  DATA_FILE=input_data/aam_jul8_2021_allchr.any_tinnitus.maf01.ADD.resultsa.fuma.gz
  LD_VCF=/mnt/ukbb/locuszoom/data/hrc_aam/HRC.r1-1.EGA.GRCh37.chr{CHR}.impute.plink.AFR.vcf.gz
  PREFIX=locuszoom_afr
elif [[ $ANCESTRY == "AMR" ]]; then
  DATA_FILE=input_data/his_jul8_2021_allchr.any_tinnitus.maf01.ADD.resultsa.fuma.gz
  LD_VCF=/mnt/ukbb/locuszoom/data/hrc_amr/HRC.r1-1.EGA.GRCh37.chr{CHR}.impute.plink.AMR.vcf.gz
  PREFIX=locuszoom_amr
elif [[ $ANCESTRY == "EUR" ]]; then
  DATA_FILE=input_data/ukbbcoding3relatednocov_mvpanytinnitusnocov_ssw1.tbl.fuma.gz
  LD_VCF=/mnt/ukbb/adam/ptsd/1000_unrel_vcf/UKB_tinnitus_eur_unrelated_1000_{CHR}.vcf.gz
  PREFIX=locuszoom_eur
elif [[ $ANCESTRY == "TRANS" ]]; then
  DATA_FILE=input_data/ukbbcoding3_plus_mvp_transethnic_broad_jul8_2021_withhet1.tbl.fuma.gz
  LD_VCF=/mnt/ukbb/adam/ptsd/1000_unrel_vcf/UKB_tinnitus_eur_unrelated_1000_{CHR}.vcf.gz
  PREFIX=locuszoom_trans
else
  usage
fi

# make input/output directories
mkdir -p inputs/${ANCESTRY}
mkdir -p outputs/${ANCESTRY}

TRANS_IND_COL=$(head -n 1 ${CONFIG_FILE} | awk '{for(i = 1; i <= NF; i++){if($i == "RUN TRANS"){print i-1}}}'
EUR_IND_COL=$(head -n 1 ${CONFIG_FILE} | awk '{for(i = 1; i <= NF; i++){if($i == "RUN EUR"){print i-1}}}'
AMR_IND_COL=$(head -n 1 ${CONFIG_FILE} | awk '{for(i = 1; i <= NF; i++){if($i == "RUN AMR"){print i-1}}}'
AFR_IND_COL=$(head -n 1 ${CONFIG_FILE} | awk '{for(i = 1; i <= NF; i++){if($i == "RUN AFR"){print i-1}}}'
if [[ $TRANS_IND_COL == "" ]]; then TRANS_IND_COL=6; fi
if [[ $EUR_IND_COL == "" ]]; then EUR_IND_COL=7; fi
if [[ $AMR_IND_COL == "" ]]; then AMR_IND_COL=8; fi
if [[ $AFR_IND_COL == "" ]]; then AFR_IND_COL=9; fi
{
read #skip first line
while IFS=$'\t' read -r -a row; do
  SNP=${row[0]}
  CHR=${row[1]}
  POS=${row[2]}
  FLANK=${row[3]}
  WINDOW=$(expr 500000 + ${FLANK/MB/000000})
  # set ld_vcf variable
  ld_vcf=$(echo $LD_VCF | sed s/{CHR}/${CHR}/g)
  # Create input file
  echo "RUNNING SNP: $SNP"
  echo -e "CHR: $CHR\tPOS: $POS\tWINDOW: $WINDOW\t"
  RUN_TRANS=${row[$TRANS_IND_COL]}
  RUN_EUR=${row[$EUR_IND_COL]}
  RUN_AMR=${row[$AMR_IND_COL]}
  RUN_AFR=${row[$AFR_IND_COL]}
  if [[ $ANCESTRY == "TRANS" ]] && [[ $RUN_TRANS -eq 1 ]]; then
    zcat ${DATA_FILE} | \
      awk -v CHR=$CHR -v POS=$POS -v WINDOW=$WINDOW 'BEGIN{OFS="\t"}{if (NR == 1 ) print "SNP", "P"; else if ($1 == CHR && $2 >= POS - WINDOW && $2 <= POS + WINDOW) print $3,$9}' \
      > inputs/${ANCESTRY}/${PREFIX}_${SNP}.tsv
  elif [[ $ANCESTRY == "EUR" ]] && [[ $RUN_EUR -eq 1 ]]; then
    zcat ${DATA_FILE} | \
      awk -v CHR=$CHR -v POS=$POS -v WINDOW=$WINDOW 'BEGIN{OFS="\t"}{if (NR == 1 ) print "SNP", "P"; else if ($1 == CHR && $2 >= POS - WINDOW && $2 <= POS + WINDOW) print $3,$9}' \
      > inputs/${ANCESTRY}/${PREFIX}_${SNP}.tsv
  elif [[ $ANCESTRY == "AMR" ]] && [[ $RUN_AMR -eq 1 ]]; then
    zcat ${DATA_FILE} | \
      awk -v CHR=$CHR -v POS=$POS -v WINDOW=$WINDOW 'BEGIN{OFS="\t"}{if (NR == 1 ) print "SNP", "P"; else if ($2 == CHR && $3 >= POS - WINDOW && $3 <= POS + WINDOW) print $1,$9}' \
      > inputs/${ANCESTRY}/${PREFIX}_${SNP}.tsv
  elif [[ $ANCESTRY == "AFR" ]] && [[ $RUN_AFR -eq 1 ]]; then
      zcat ${DATA_FILE} | \
        awk -v CHR=$CHR -v POS=$POS -v WINDOW=$WINDOW 'BEGIN{OFS="\t"}{if (NR == 1 ) print "SNP", "P"; else if ($2 == CHR && $3 >= POS - WINDOW && $3 <= POS + WINDOW) print $1,$9}' \
        > inputs/${ANCESTRY}/${PREFIX}_${SNP}.tsv
  fi
  # Create european output
  python2 /mnt/ukbb/locuszoom/bin/locuszoom --db /mnt/ukbb/adam/tinnitus_gwas/jama_oto/locuszoom_inputs/my_database.db --build hg19 \
    --metal inputs/${ANCESTRY}/${PREFIX}_${SNP}.tsv --markercol SNP --pvalcol P --ignore-vcf-filter --refsnp $SNP --flank $FLANK \
    --ld-vcf ${ld_vcf} --prefix outputs/${ANCESTRY}/${PREFIX}_
done
} < ${CONFIG_FILE}
