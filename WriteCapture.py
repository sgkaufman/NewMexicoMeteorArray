#!/usr/bin/env python

"""
Version of 04-May-2021; Bytes: 4861
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
# from RMS.ExternalScript import makeDateTime
# from RMS.ExternalScript import makeLogFile

def makeDateTime(time_str):
    """ 
    Create and return a datetime object from the time_str,
    assumed to be in ISO format with blank separator between date and time.
    I.e., "2020-05-20 02:33:45.123456". No time zone. 
    Only needed for Python 2, which does not have 
    datetime.datetime.fromisoformat(time_str) method.
    We add half a second using a timedelta to round up to nearest second.
    """
    half_sec = datetime.timedelta(milliseconds = 500)
    parts = time_str.split(' ')
    date = parts[0]
    hour = parts[1]
    date_parts = date.split('-')
    hour_parts = hour.split(':')
    sec_parts = (hour_parts[2]).split('.')
    return datetime.datetime(year = int(date_parts[0]), \
                             month = int(date_parts[1]), \
                             day = int(date_parts[2]), \
                             hour = int(hour_parts[0]), \
                             minute = int(hour_parts[1]), \
                             second = int(sec_parts[0]), \
                             microsecond = int(sec_parts[1]) ) \
        + half_sec


def makeLogFile(log_file_dir, prefix, time_arg=None):
    
    # Create a log file to provide as stdout and stderr for
    # the subprocess.calls of the shell scripts.
    # Return the file pointer to the log file in OPEN state.
    # time_arg, if given, is a date string of the form
    # "2020-05-20 02:33:45.123456". Cannot include a timezone at the end.

    if time_arg is None:
        time_to_use = datetime.datetime.utcnow()
    else:
        time_to_use = makeDateTime(time_arg)

    log_filename = prefix + "_{0}_{1}_{2}".format \
        (time_to_use.year, \
         time_to_use.month, \
         time_to_use.day)
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
    time_str = start_time.isoformat(' ')
    print ("Time string is: %s" % time_str)
    time_file = makeLogFile('/home/pi/RMS_data/logs/', "CaptureTimes", time_str)

    with open(time_file, 'w+') as time_fd:
        print(time_str, file=time_fd)
        print("%d" % duration_int, file=time_fd)
