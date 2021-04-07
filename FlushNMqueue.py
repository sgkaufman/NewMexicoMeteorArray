#!/usr/bin/env python

"""
FlushNMqueue.py (2055 bytes) 07-Apr, 2021
This script flushes the queue for files uploaded to New Mexico Meteor Array Server.

It contains code fragments from ExternalScript.py v0.8, Dated 03/25/2021 (14564 bytes)
"""

from __future__ import print_function

import os
import sys
import copy
import logging
import fnmatch
import argparse
import subprocess
import time
import datetime

from RMS.CaptureDuration import captureDuration
import RMS.ConfigReader
from RMS.UploadManager import UploadManager
from RMS.Logger import initLogging
import ftplib
from ftplib import FTP_TLS

####################################

if __name__ == "__main__":

    config = RMS.ConfigReader.loadConfigFromDirectory(None, "/home/pi/source/RMS/.config")

    print("Running FlushNMqueue.py, 07-Apr, 2021, byte count = 2055, flushing the NM upload queue...")

    log_upload=True
    log_script=False

    # Variable definitions
    remote_dir = '/Users/meteorstations/Public'
    RMS_data_dir_name = os.path.abspath("/home/pi/RMS_data/")
    log_dir_name = os.path.join(RMS_data_dir_name, 'logs/')

    # Create the config object for New Mexico Meteor Array purposes
    nm_config = copy.copy(config)
    nm_config.stationID = 'meteorstations'
    nm_config.hostname = '10.8.0.61' # 69.195.111.36 for Bluehost
    nm_config.remote_dir = remote_dir
    nm_config.upload_queue_file = 'NM_FILES_TO_UPLOAD.inf'

    log_file_name ="/dev/null"

    with open(log_file_name, 'w+') as log_file:

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
