#!/usr/bin/env bash
# Backup.sh
# script backs up key files so microSD can be swapped
# User is responsible for changing the variable "destination"
# to the name of their own USB drive.

printf "Backup.sh 09-Jul, 2021, byte count ~1070 : backs up files prior to microSD swap\n"

destination="/media/pi/D25B-C884/US000N_Backup/"

mkdir ${destination} 2> /dev/null
mkdir ${destination}source 2> /dev/null
mkdir ${destination}source/RMS 2> /dev/null
mkdir ${destination}source/RMS/RMS 2> /dev/null
mkdir ${destination}RMS_data 2> /dev/null
mkdir ${destination}RMS_data/csv 2> /dev/null

cp -r "$HOME"/.ssh ${destination}
cp -r "$HOME"/Desktop ${destination}
cp "$HOME"/source/RMS/*.sh  ${destination}/source/RMS
cp "$HOME"/source/RMS/platepar_cmn2010.cal ${destination}/source/RMS
cp "$HOME"/source/RMS/mask.bmp ${destination}/source/RMS
cp "$HOME"/source/RMS/.config ${destination}/source/RMS
cp "$HOME"/source/RMS/RMS/ExternalScript.py ${destination}/source/RMS/RMS
cp "$HOME"/RMS_data/csv/*_fits_counts.txt ${destination}/RMS_data/csv
cp "$HOME"/RMS_data/myup.txt ${destination}/RMS_data

if [[ -f /etc/openvpn/ovpn.conf ]]
   then
       cp /etc/openvpn/ovpn.conf "${destination}"/ovpn.conf
fi
   
printf "\nBackup.sh has completed\n"
ls ${destination}

exit 0
