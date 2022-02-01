#!/bin/bash
echo -e "============\nEUR ancestry\n============" > run_locuszoom.log
bash src/run_locuszoom.sh -a EUR -f config/freeze3_proxy.tsv &>> run_locuszoom.log
#echo -e "============\nAFR ancestry\n============" >> run_locuszoom.log
#bash src/run_locuszoom.sh -a AFR -f config/tinnitus_hits.tsv &>> run_locuszoom.log
#echo -e "============\nAMR ancestry\n============" >> run_locuszoom.log
#bash src/run_locuszoom.sh -a AMR -f config/tinnitus_hits.tsv &>> run_locuszoom.log
#echo -e "==============\nTRANS ancestry\n==============" >> run_locuszoom.log
#bash src/run_locuszoom.sh -a TRANS -f config/tinnitus_hits.tsv &>> run_locuszoom.log
python3 src/create_pngs.py
