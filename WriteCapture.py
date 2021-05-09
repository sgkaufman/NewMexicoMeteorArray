#!/usr/bin/env python

"""
Version of 05-May-2021; Bytes: 3496
Version 0.1, SGK, 6/28/2020. This file belongs in directory
/home/pi/source/RMS/RMS/.
This file calls the RMS function captureDuration (from RMS.CaptureDuration)
and writes it to a log file for use by the shell script RecordWatchdog.sh.
The log file is named CaptureTimes_yyyy_mm_dd, and is put into directory
~/RMS_data/logs/, and writes the start time in ISO format, and capture time
as an integer, rounded from the floating point value retutrn by captureDuration.
"""
from __future__ import print_function
import os
import datetime
import argparse
from RMS.CaptureDuration import captureDuration

def makeLogFile(log_file_dir, prefix, time_arg=None):
    
    # Create a log file to provide as stdout and stderr for
    # the subprocess.calls of the shell scripts.
    # Return the file pointer to the log file in OPEN state.
    # time_arg, if given, is a datetime object.

    if time_arg is None:
        time_to_use = datetime.datetime.utcnow()
    else:
        time_to_use = time_arg

    log_filename = prefix + "_" + \
        time_to_use.strftime( '%Y_%m_%d' ) + ".log"

    full_filename = log_file_dir + log_filename
    print("Creating log file name %s\n" % full_filename)
    return full_filename

########################################################################

if __name__ == "__main__":

    config_parser = argparse.ArgumentParser(description="""Compute and write out the start time and capture duration given the latituude, longitude, and elevation of the station.""")
    config_parser.add_argument('--latitude', type=float, \
                               help="Station latitude from .config file")
    config_parser.add_argument('--longitude', type=float, \
                               help="Station longitude from .config file")
    config_parser.add_argument('--elevation', type=float, \
                               help="Station elevation from .config file")
    args = config_parser.parse_args()

    print ("WriteCapture.py, Latitude: ", args.latitude)
    print ("WriteCapture.py, Longitude: ", args.longitude)
    print ("WriteCapture.py, Elevation: ", args.elevation)
    
    # Compute and write out the next start time and capture timedatetime.
    start_time, duration = captureDuration(args.latitude, \
                                           args.longitude, \
                                           args.elevation)
    if (start_time == True):
        current = datetime.datetime.utcnow()
        twelve = datetime.timedelta(hours=12)
        prev = current - twelve
        start_time, duration = captureDuration(args.latitude, \
                                               args.longitude, \
                                               args.elevation, \
                                               current_time=prev)
        print ("WriteCapture.py, Latitude: ", args.latitude)
        print ("WriteCapture.py, Longitude: ", args.longitude)
        print ("WriteCapture.py, Elevation: ", args.elevation)
        print ("WriteCapture.py, current_time: %s" % current)

    duration_int = round(duration)
    time_str = start_time
    print ("Time string is: %s" % time_str)
    time_file = makeLogFile('/home/pi/RMS_data/logs/', "CaptureTimes", time_str)

    with open(time_file, 'w+') as time_fd:
        print(time_str, file=time_fd)
        print("%d" % duration_int, file=time_fd)
