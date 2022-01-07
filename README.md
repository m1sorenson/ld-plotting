# LD Plotting
Wrapper for locuszoom, used to plot linkage disequilibrium of genome-wide significant SNPs
Revised Dec 14, 2021 - Michael

Uses [locuszoom](http://locuszoom.org/) for plotting

## Prerequisites
Libraries:
- locuszoom
- python3
- python libraries: run `pip install -r requirements.txt`

Other:
- GWAS summary statistics files for each ancestry of interest, the ones I used were from the [Tinnitus_sumstats_v2 dropbox](https://www.dropbox.com/sh/ax5eu7ilwuaa4ky/AACY03gX1MUTwJVBNmprhygGa?dl=0)
- Reference VCF file for each ancestry of interest

## Configuration
To configure the SNPs you want to plot LD for, create a .tsv (tab-separated values) file in the `config` folder. The file should have the following columns (in order):
- SNP: RS ID of the SNP of interest
- CHR: Chromosome number
- POSITION: Position (base pairs)
- FLANK: Window around SNP to plot LD (in Mega-basepairs, e.g. 1MB would plot all SNPs 1000000 base pairs before or after the SNP of interest)
- ANCESTRY: which ancestry the SNP was found to be significant in
- RUN TRANS: whether to run the SNP in TRANS-ancestry (1/0) - if 1, the script will run it, if 0, the script will skip it
- RUN EUR: whether to run the SNP in EUR-ancestry (1/0) - if 1, the script will run it, if 0, the script will skip it
- RUN AMR: whether to run the SNP in AMR-ancestry (1/0) - if 1, the script will run it, if 0, the script will skip it
- RUN AFR: whether to run the SNP in AFR-ancestry (1/0) - if 1, the script will run it, if 0, the script will skip it

IMPORTANT NOTE: make sure the column names match exactly, especially "RUN TRANS", "RUN EUR", "RUN AMR", and "RUN AFR"

Note: the last four columns are especially useful when a SNP errors, because you can troubleshoot the issue and re-run just one or a few SNPs

Examples of config files can be found in the config folder.

## Set up
Before this script can be used to run locuszoom, there are a few things that need changing in `run_locuszoom.sh`:
- the variable `DATA_FILE` on lines 20-39 should be changed to the GWAS summary statistics file of each respective ancestry
- the variable `LD_VCF` on lines 20-39 should be changed to the reference VCF file of each respective ancestry
- the database on line 62 after the `--db` flag should be changed if not using the nievergeltlab server
- the awk command on lines 70, 74, 78, 82 may need to be changed if the input data files don't have the chromosome column as column 1 for TRANS/EUR and column 2 for AMR/AFR

## Usage
To run locuszoom on all ancestries, just edit `run_all.sh` to use the name of your configuration file, then run:
```
./main.sh
```

This will run locuszoom on all ancestries for all SNPs specified in the config file, and create PNGs for each SNP, and save them to outputs/final_pngs. The error and output will be printed to run_locuszoom.log

## Other usage notes
- If you would like to add more ancestries, just copy the `elif` block on line 25-28 of `run_locuszoom.sh` and change the ancestry to whatever you would like, and set the DATA_FILE and LD_VCF to the GWAS summary statistics file and reference file respectively.

## Troubleshooting
If a SNP errors, the first thing to check is that the RS ID is actually in both the summary statistics file and the reference VCF. If it is not in the reference VCF, all the SNPs will show up grey, and if it is not in the summary statistics file, there will be an error.
