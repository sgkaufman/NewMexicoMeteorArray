#!/bin/bash
echo "Starting RMS live stream..."

source ~/vRMS/bin/activate
cd ~/source/RMS
python -m Utils.ShowLiveStream --config /home/pi/source/Stations/US0001/.config

read -p "Press any key to continue... "
$SHELL
