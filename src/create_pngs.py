#!/usr/bin/python3
from pdf2image import convert_from_path
import glob
import os
import sys

if not os.path.exists('outputs/final_pngs'):
    os.mkdir('outputs/final_pngs')

for ancestry in ['AFR', 'AMR', 'EUR', 'TRANS']:
    for ld_dir in os.listdir('outputs/' + ancestry):
        ld_path = 'outputs/' + ancestry + '/' + ld_dir + '/'
        pdf = glob.glob(ld_path + '*.pdf')
        if len(pdf) == 0:
            print(ld_dir)
        else:
            pdf= pdf[0].replace('\\', '/')
            pages = convert_from_path(pdf, 1000)
            pages[0].save('outputs/final_pngs/' + ld_dir + '.png', 'PNG')
