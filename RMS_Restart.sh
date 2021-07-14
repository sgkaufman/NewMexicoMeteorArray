#!/usr/bin/env bash
# RMS_Restart.sh
# Runs RMS_Update, then RMS_StartCatpure

printf "RMS_Restart.sh 13-Jul, 2021, byte count 388 : Runs RMS_Update, then RMS_StartCatpure\n"

source vRMS/bin/activate
cd source/RMS

printf "\nRunning RMS_Update...\n"
./Scripts/RMS_Update.sh

printf "\nRunning RMS_StartCatpure...\n"
./Scripts/RMS_StartCapture.sh

printf "\nRMS_Restart has completed\n"

