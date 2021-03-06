#!/bin/bash

log_dir="/home/pi/RMS_data/logs"

# Find the latest CaptureTimes file in the log directory

capture_file=$(ls -lt $log_dir/"CaptureTimes"* | sed -n 1p | cut -d' ' -f9)
echo $capture_file
read time < $capture_file
mo=$(date --date="$time" +%m)
day=$(date --date="$time" +%d)
yr=$(date --date="$time" +%Y)

log_file=$log_dir/"RMS_RecordWatchdog_"$mo"_"$day"_"$yr".log"

cd /home/pi/source/RMS/Scripts
echo Logging RMS_StartWatchdog.sh to $log_file ...
./RecordWatchdog.sh >> $log_file &
exit 0
