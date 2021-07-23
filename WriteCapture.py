#!/usr/bin/env python

"""
Version of 23-Jul-2021; Bytes: 3252
Version 0.1, SGK, 6/28/2020. This file belongs in directory
$HOME/source/RMS/RMS/.
This file calls the RMS function captureDuration (from RMS.CaptureDuration)
and writes the capture start time and capture duration to a log file
called "CaptureTime.log". It is used by the shell script RecordWatchdog.sh
and other utilities.
The log file is put into directory ~/RMS_data/logs/,
and writes the start time in ISO format, and capture time as an integer,
rounded from the floating point value returned by captureDuration.
"""
from __future__ import print_function
import os
import datetime
import argparse
import ephem
from RMS.CaptureDuration import captureDuration

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
    lat = args.latitude
    lon = args.longitude
    elev = args.elevation

    print ("WriteCapture.py, Latitude:  ", lat)
    print ("WriteCapture.py, Longitude: ", lon)
    print ("WriteCapture.py, Elevation: ", elev)

    # Compute and write out the next start time and capture time datetime.
    start_time, duration_float = captureDuration(lat, lon, elev)
    if start_time is True:
        # We will use the ephemeris code directly
        # to compute the previous sunset time, to get start_time and duration.
        # Code copied fromCaptureDuration.py

        # Initialize the observer
        o = ephem.Observer()
        o.lat = str(lat)
        o.long = str(lon)
        o.elevation = elev

        # The Sun should be about 5.5 degrees below the horizon when the capture should begin/end
        o.horizon = '-5:26'
        # Calculate the locations of the Sun
        s = ephem.Sun()
        s.compute()
        # End of code segment copied from CaptureDuration.py

        prev_set = o.previous_setting(s).datetime()
        next_rise = o.next_rising(s).datetime()
        now = datetime.datetime.utcnow()

        # Ensure that prev_set occurs before next_rise
        if next_rise > prev_set:
            duration_datetime = next_rise - now
        else:
            duration_datetime = 0
        duration_float = duration_datetime.total_seconds()
        start_time = prev_set

    # end of if statement
    duration_int = round(duration_float)
    print ("Time string is: %s" % start_time)

    with open(os.path.join(os.path.expanduser('~'), "RMS_data/logs/CaptureTimes"), \
              'w+') as time_fd:
        print(start_time, file=time_fd)
        print("%d" % duration_int, file=time_fd)
