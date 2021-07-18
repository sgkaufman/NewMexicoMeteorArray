#!/bin/bash

# CaptureTimes.sh is a hacked version of StartCaptureWatchdog.sh from 09-July-2021
# 14-July, 2021; Byte count: 1477
#
# Date: 09-Jul-2021; Byte count: 2728
# Starts the RecordWatchdog.sh monitoring program
# (to restart RMS if capture stops).

# Variable definitions
declare log_dir="$HOME""/RMS_data/logs"
declare config_file="$HOME""/source/RMS/.config"
declare latitude longitude elevation

sudo logger 'CaptureTimes.sh started'

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
python -m RMS.CaptureTimes \
       --latitude $latitude \
       --longitude $longitude \
       --elevation $elevation
popd

#
exit 0
