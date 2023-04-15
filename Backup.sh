#!/usr/bin/env bash
# Backup.sh
# script backs up key files so microSD can be swapped

printf "Backup.sh 14-Apr 2023, byte count ~887 : backs up files prior to microSD swap\n"

destination="/media/usbdrive/Swap_microSD"

mkdir ${destination}
mkdir ${destination}/source
mkdir ${destination}/source/NMMA
mkdir ${destination}/source/RMS
mkdir ${destination}/RMS_data
mkdir ${destination}/RMS_data/csv

cp -r "$HOME"/.ssh ${destination}
cp -r "$HOME"/Desktop ${destination}
cp "$HOME"/source/NMMA/*.*  ${destination}/source/NMMA
cp "$HOME"/source/RMS/platepar_cmn2010.cal ${destination}/source/RMS
cp "$HOME"/source/RMS/mask.bmp ${destination}/source/RMS
cp "$HOME"/source/RMS/.config ${destination}/source/RMS
cp "$HOME"/RMS_data/csv/*_fits_counts.txt ${destination}/RMS_data/csv
cp "$HOME"/RMS_data/myup.txt ${destination}/RMS_data

printf "\nBackup.sh has completed\n"
ls ${destination}
