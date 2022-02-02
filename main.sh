#!/bin/bash
now=$(date +'%m_%d_%Y_%H-%M')
logfile=logs/${now}.log
echo -e "============\nEUR ancestry\n============" > $logfile
bash src/run_locuszoom.sh -a EUR -f config/freeze3_hits.tsv &>> $logfile
#echo -e "============\nAFR ancestry\n============" >> $logfile
#bash src/run_locuszoom.sh -a AFR -f config/tinnitus_hits.tsv &>> $logfile
#echo -e "============\nAMR ancestry\n============" >> $logfile
#bash src/run_locuszoom.sh -a AMR -f config/tinnitus_hits.tsv &>> $logfile
#echo -e "==============\nTRANS ancestry\n==============" >> $logfile
#bash src/run_locuszoom.sh -a TRANS -f config/tinnitus_hits.tsv &>> $logfile
python3 src/create_pngs.py
