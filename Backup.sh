#!/usr/bin/env bash
# Backup.sh
# script backs up key files so microSD can be swapped
# User is responsible for changing the variable "destination"
# to the name of their own USB drive.

printf "Backup.sh 09-Jul, 2021, byte count ~1130 : backs up files prior to microSD swap\n"

# set station specific USB drive designation
destination="/media/pi/D25B-C884/US000N_Backup/Swap_MicroSD"

mkdir ${destination}
mkdir ${destination}/source
mkdir ${destination}/source/RMS
mkdir ${destination}/source/RMS/RMS
mkdir ${destination}/RMS_data
mkdir ${destination}/RMS_data/csv

cp -r "$HOME"/.ssh ${destination}
cp -r "$HOME"/Desktop ${destination}
cp "$HOME"/source/RMS/*.sh  ${destination}/source/RMS
cp "$HOME"/source/RMS/platepar_cmn2010.cal ${destination}/source/RMS
cp "$HOME"/source/RMS/mask.bmp ${destination}/source/RMS
cp "$HOME"/source/RMS/.config ${destination}/source/RMS
cp "$HOME"/source/RMS/RMS/ExternalScript.py ${destination}/source/RMS/RMS
cp "$HOME"/RMS_data/csv/*_fits_counts.txt ${destination}/RMS_data/csv
cp "$HOME"/RMS_data/myup.txt ${destination}/RMS_data

printf "\nBackup.sh has completed\n"
ls ${destination}
