#!/usr/bin/env bash
# Backup.sh
# script backs up key files so microSD can be swapped
# script can be located on ~/Desktop

printf "Backup.sh 14-April, 2020: backs up files prior to microSD swap\n"

destination="/media/pi/32GB_F32_2/Swap_microSD"

mkdir ${destination}
mkdir ${destination}/source
mkdir ${destination}/source/RMS
mkdir ${destination}/source/RMS/RMS
mkdir ${destination}/RMS_data
mkdir ${destination}/RMS_data/csv

cp -r /home/pi/.ssh ${destination}
cp -r ~/Desktop ${destination}
cp /home/pi/source/RMS/*.sh  ${destination}/source/RMS
cp /home/pi/source/RMS/platepar_cmn2010.cal ${destination}/source/RMS
cp /home/pi/source/RMS/mask.bmp ${destination}/source/RMS
cp /home/pi/source/RMS/.config ${destination}/source/RMS
cp /home/pi/source/RMS/RMS/ExternalScript.py ${destination}/source/RMS/RMS
cp /home/pi/RMS_data/csv/*_fits_counts.txt ${destination}/RMS_data/csv
cp /home/pi/RMS_data/myup.txt ${destination}/RMS_data

printf "\nBackup.sh has completed\n"
ls ${destination}
