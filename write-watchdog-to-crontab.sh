#!/bin/bash

# Version 0.1, dated 29-Sep-2021, byte count=1363
# This function writes an entry in the crotab of user pi
# to run StartCaptureWatchdog.sh ten minutes from time of call.
# It is called from RecordWatchdog.sh when it must reboot
# during capture. This is just the demonstratio/test version.
# A copy of this fuction is in RecordWatchdog.sh.

function write-watchdog-to-crontab () {
    declare -i local now
    declare -i new_start ns_mins ns_hrs
    cron_file="$HOME""/RMS_data/logs/cron_update_file.txt"
    start_script="$HOME""/source/RMS/Scripts/StartCaptureWatchdog.sh"
    
    now=$(date +%s)
    new_start=$((now+600))
    ns_time=$(date --date=@"$new_start" +%M:%H)
    # The grepping in the next two lines is needed to strip off
    # leading zeroes from the minute and hour. 
    # A leading zero makes bash interpret what follows as octal.
    # Values of 08 and 09 therefore cause errors.
    ns_mins=$(echo $ns_time | cut -d':' -f1 | grep -o [1-9][0-9]*)
    ns_hrs=$(echo $ns_time | cut -d':' -f2 | grep -o [1-9][0-9]*)

    # Now overwrite whatever may be in $cron_file.
    # Else there will be nasty crontab entry buildup.
    env printf "%d %d * * * %s\n" $ns_mins $ns_hrs "$start_script" \
	> "$cron_file"
	
    # Update the crontab entry
    crontab -l -u pi | cat - "$cron_file" | crontab -u pi -
}

write-watchdog-to-crontab

