#!/usr/bin/env python

"""
CaptureTimes.py is a hacked version of WriteCapture.py
 capture time information is written to a static file named
 ~/RMS_data/logs/CaptureTimes.log
Version of 20-July-2021; Bytes: 3297

Version of 21-May-2021; Bytes: 3820
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

    print ("CaptureTimes.py, Latitude: ", lat)
    print ("CaptureTimes.py, Longitude: ", lon)
    print ("CaptureTimes.py, Elevation: ", elev)

    # Compute and write out the next start time and capture timedatetime.
    start_time, duration = captureDuration(lat, lon, elev)
    if start_time:
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
        # End of code segment copied from CaptuureDuration.py

        prev_set = o.previous_setting(s).datetime()
        next_rise = o.next_rising(s).datetime()
        now = datetime.datetime.utcnow()

        # Ensure that prev_set occurs before next_rise
        if next_rise > prev_set:
            duration = next_rise - now
        else:
            duration = 0
        duration = duration.total_seconds()
        start_time = prev_set

    duration_int = round(duration)
    print ("Time string is: %s" % start_time)

    with open(os.path.join(os.path.expanduser('~'), "RMS_data/logs/CaptureTimes.log"), 'w') as time_fd:
        print(start_time, file=time_fd)
        print("%d" % duration_int, file=time_fd)
