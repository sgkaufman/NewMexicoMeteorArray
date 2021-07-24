#!/usr/bin/env bash
# RMS_Restart.sh
# Runs RMS_Update, then RMS_StartCatpure

printf "RMS_Restart.sh 24-Jul, 2021, byte count 457 : Runs RMS_Update, WriteCapture, then RMS_StartCapture\n"

source vRMS/bin/activate
cd source/RMS

printf "\nRunning RMS_Update...\n"
./Scripts/RMS_Update.sh

printf "\nRunning WriteCapture...\n"
./WriteCapture.sh

printf "\nRunning RMS_StartCatpure...\n"
./Scripts/RMS_StartCapture.sh

printf "\nRMS_Restart has completed\n"
