#!/bin/bash
# update.sh	automate file config and copy, printf line below for date of last update

cd "$HOME"/Desktop

update_sh () {
printf "Updating %s\n" "$1"
chmod u+x "$1"
cp "$1" "$HOME"/Desktop/Backups
mv "$1" "$HOME"/source/RMS
}

update_sh_Scripts () {
printf "Updating %s\n" "$1"
chmod u+x "$1"
cp "$1" "$HOME"/Desktop/Backups
mv "$1" "$HOME"/source/RMS/Scripts
}

update_py () {
printf "Updating %s\n" "$1"
cp "$1" "$HOME"/Desktop/Backups
mv "$1" "$HOME"/source/RMS/RMS
}

move_file () {
printf "Moving %s\n" "$1"
cd "$HOME"/source/RMS
cp "$1" TimeLapse.sh
}

backup_file () {
printf "Backing up %s\n" "$1"
mv "$HOME"/Desktop/"$1" "$HOME"/Desktop/Backups/"$1"
}

save_previous () {
printf "Saving previous version of %s\n" "$1"
mkdir "$HOME"/Desktop/Backups/old
mv "$HOME"/Desktop/Backups/"$1" "$HOME"/Desktop/Backups/old/"$1"
}


printf "\nupdate.sh, 10-Jul, 2021, byte count ~1473 : automate file config and copy\n"

save_previous Backup.sh
update_sh Backup.sh
save_previous BackupToUSB.sh
update_sh BackupToUSB.sh

update_sh FixIt.sh
update_sh FlushNMqueue.sh
update_sh TimeLapse.sh

update_sh_Scripts RecordWatchdog.sh
update_sh_Scripts StartCaptureWatchdog.sh

update_py FlushNMqueue.py
#update_py ExternalScript.py

backup_file Turn_Features_On_Off.txt
backup_file update.sh

#move_file TimeLapse2.sh

printf "Done updating files\n"
printf "Remember to edit any badkup scripts for correct thumb drive name!\n"
read -p "Press any key to continue... " -n1 -s
