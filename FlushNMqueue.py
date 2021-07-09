#!/usr/bin/env python

"""
This script flushes the queue for files uploaded to New Mexico Meteor Array Server.

It contains code fragments from ExternalScript.py v0.8, Dated 03/25/2021 (14564 bytes)
"""

from __future__ import print_function

import copy
import logging

import RMS.ConfigReader
from RMS.UploadManager import UploadManager
from RMS.Logger import initLogging

####################################

if __name__ == "__main__":

    config = RMS.ConfigReader.loadConfigFromDirectory(None, "$HOME/source/RMS/.config")

    print("Running FlushNMqueue.py, 09-Jul, 2021, byte count 1457: flushing the NM upload queue...")

    # Create the config object for New Mexico Meteor Array purposes
    nm_config = copy.copy(config)
    nm_config.stationID = 'meteorstations'
    nm_config.hostname = '10.8.0.61' # 69.195.111.36 for Bluehost
    nm_config.remote_dir = '/Users/meteorstations/Public'
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
