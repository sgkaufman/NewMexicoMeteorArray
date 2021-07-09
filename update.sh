#!/bin/bash
# update.sh	automate file config and copy, printf line below for date of last update

cd $HOME/Desktop

update_sh () {
printf "Processing %s\n" "$1"
chmod u+x "$1"
cp "$1" $HOME/Desktop/Backups
cp "$1" $HOME/source/RMS
rm "$1"
}

update_py () {
printf "Processing %s\n" "$1"
cp "$1" $HOME/Desktop/Backups
cp "$1" $HOME/source/RMS/RMS
rm "$1"
}

move_file () {
printf "Processing %s\n" "$1"
cd $HOME/source/RMS
cp "$1" TimeLapse.sh
}

backup_file () {
printf "Processing %s\n" "$1"
mv $HOME/Desktop/"$1" $HOME/Desktop/Backups/"$1"
}


printf "\nupdate.sh, 09-Jul, 2021, byte count ~766 : automate file config and copy\n"

update_sh TimeLapse.sh
#backup_file update.sh

#move_file TimeLapse2.sh
#update_py ExternalScript.py

printf "Done updating files\n"
