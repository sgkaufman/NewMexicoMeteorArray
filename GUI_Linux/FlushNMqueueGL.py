#!/usr/bin/env python

"""
This script flushes the queue for files uploaded to New Mexico Meteor Array Server. Dated 17-Feb-2023; byte count = 1979

It contains code fragments from ExternalScriptRPi.py v1.0, 
dated 07-Aug-2021 (13131 bytes)
"""

from __future__ import print_function

import os
import copy
import logging
import argparse

import RMS.ConfigReader
from RMS.UploadManager import UploadManager
from RMS.Logger import initLogging

####################################

if __name__ == "__main__":

    nmp = argparse.ArgumentParser(description="""Upload files to New_Mexico_Server, and optionally move other files to storage devices, create a TimeLapse.mp4 file, and reboot the system after all processing.""")

    nmp.add_argument('--config', type=str, \
                     help="The full path to the directory containing the .config file for the camera.")

    args = nmp.parse_args()

    if args.config is None:
        print ("config argument not present! Exiting ...")
        sys.exit()

    config = RMS.ConfigReader.loadConfigFromDirectory('.', args.config)
 
    print("Running FlushNMqueueGL.py, 17-Feb-2023, byte count 1979: flushing the NM upload queue...")
    # Create the config object for New Mexico Meteor Array purposes
    nm_config = copy.copy(config)
    nm_config.stationID = 'pi'
    nm_config.hostname = '10.8.0.46'
    nm_config.remote_dir = '/home/pi/RMS_Station_data'
    nm_config.upload_queue_file = 'NM_FILES_TO_UPLOAD.inf'

    initLogging(config, "NM_UPLOAD_")
    # Get the logger handle. 
    log = logging.getLogger("logger.FlushNMqueue")

    # Upload files to the NM Server
    # create the upload manager for the local files
    upload_manager = UploadManager(nm_config)
    upload_manager.start()

    # Begin the upload!
    upload_manager.uploadData()

    upload_manager.stop()

    log.info("FlushNMqueue has finished!")

####################################
