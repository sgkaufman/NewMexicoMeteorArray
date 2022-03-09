#!/usr/bin/env bash
# Restore the files written to the USB drive from Backup.sh.
#
# Initial version by SGK, 09-Mar-2022. Byte count ~ 809 

source="/media/pi/D25B-C884/US000N_Backup"
data_dst="${HOME}/RMS_data/"
src_dst="${HOME}/source/RMS"

if [[ ! -d "${data_dst}"/csv ]]
then
    mkdir "{$data_dst}"/csv
fi

if [[ -d "${source}/csv" ]]
   then
       cp "${source}/csv"/*_fits_counts.txt "${data_dst}/csv/"
fi

if [[ -d "${source}/.ssh" ]]
   then
       cp "${source}/.ssh/"* "${HOME}/.ssh/"
       chmod 600 "${HOME}/.ssh/"
else
    printf "No .ssh directory in %s\n" "${source}"
fi

if [[ -f "${source}"/source/RMS/platepar_cmn2010.cal ]]
then
    cp "${source}"/source/RMS.platepar_cmn2010.cal "${src_dst}"/source/RMS/
else
    printf "No platepar file in %s\n" "${source}/source/RMS"
fi

if [[ -f "${source}"/ovpn.conf ]]
then
    sudo cp "${source}ovpn.conf" /etc/openvpn/
else
    printf "No ovpn.conf file at %s\n" "${source}"
fi



   
