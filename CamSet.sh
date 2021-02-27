#!/bin/bash

# CamSet.sh  script, see printf below for rev date
# 
# Mark McIntyre: for night, set them to 100, 70, 2 and 40000 respectively 
#  (the time is in microseconds, min value 100us.) 

printf 'CamSet.sh, revised 24-Feb-2021, byte count = 1242, was called with Arg1 = %s\n' "$1"
printf 'CamSet.sh can set the camera to daytime mode if Arg1 is present\n'
printf 'Otherwise the camera is set to night time mode\n'
printf 'For help with CameraControl: python -m Utils.CameraControl -h \n\n'

if [[ $1 = '' ]] ; then
    printf 'Setting camera to night time mode\n'
    python -m Utils.CameraControl SetParam Camera ElecLevel 100
    python -m Utils.CameraControl SetParam Camera GainParam Gain 60
    python -m Utils.CameraControl SetParam Camera DayNightColor 2 
    python -m Utils.CameraControl SetParam Camera ExposureParam LeastTime 40000
else
    printf 'Setting camera to daytime mode\n'
    python -m Utils.CameraControl SetParam Camera ElecLevel 30 
    python -m Utils.CameraControl SetParam Camera GainParam Gain 30 
    python -m Utils.CameraControl SetParam Camera DayNightColor 1 
    python -m Utils.CameraControl SetParam Camera ExposureParam LeastTime 100 
fi 
printf 'CamSet.sh is done setting camera parameters\n'



