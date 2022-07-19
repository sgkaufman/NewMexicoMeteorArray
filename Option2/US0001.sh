#!/bin/bash
#change the sleep duration in the line below for each station so they are staggered 2m apart
sleep 2m
source ~/vRMS/bin/activate
cd ~/source/RMS
python -m RMS.StartCapture --config ~/source/Stations/US0001/.config

