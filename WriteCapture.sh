#!/bin/bash

# WriteCapture.sh, 17-Jan, 2023, Byte count: 1830
# This is a trimmed down version of StartCaptureWatchdog.sh (09-July-2021)
# On Buster RMS stations, this file can reside in $HOME/source/NMMA and be
# called by autoexec so that the CaptureTimes.log file is written at boot
# sudo nano /etc/xdg/lxsession/LXDE-pi/autostart
# 
#  #Start Milan's watchdog
#  sleep 5
#  /home/pi/source/Scripts/RMS_watchdog.sh &
#  sleep 4
#  /home/pi/source/NMMA/WriteCapture.sh
#
# alternatively, you can call WriteCapture.sh from a cron job:
# 10 22 * * * /home/pi/source/NMMA/WriteCapture.sh

# Variable definitions:
declare log_dir="$HOME""/RMS_data/logs"
declare config_file="$HOME""/source/RMS/.config"
declare latitude longitude elevation

sudo logger 'WriteCapture.sh started'

# Step 1: Find ephemeris sunset time and capture time.
# Requires latitude, longitude, and elevation from the .config file
# The 3rd 'grep' is used to ensure that only 1 value comes back,
# even if there are multiple values (e.g., commented out in .config)
latitude=$(sed -n '/^latitude/'p "$config_file" | grep -Eo '[+-]?[0-9]+\.[0-9]+{4}' | grep -Eo -m 1 '^[+-]?[0-9]+\.[0-9]+{4}')
longitude=$(sed -n '/^longitude/'p "$config_file" | grep -Eo '[+-]?[0-9]+\.[0-9]+{4}' | grep -Eo -m 1 '^[+-]?[0-9]+\.[0-9]+{4}')
elevation=$(sed -n '/^elevation/'p "$config_file" | grep -Eo '[+-]?[0-9]+(\.[0-9]+)?' | grep -Eo -m 1 '[+-]?[0-9]+(\.[0-9]+)?')

if [ ! $elevation ]
then
    echo "Error parsing elevation in .config file - exiting ..."
    exit 1
fi

echo "Latitude: " $latitude
echo "Longitude: " $longitude
echo "Elevation: " $elevation

pushd "$HOME"/source/RMS
source "$HOME"/vRMS/bin/activate
cd "$HOME"/pi/source/NMMA
python -m WriteCapture \
       --latitude $latitude \
       --longitude $longitude \
       --elevation $elevation
popd

#
exit 0
