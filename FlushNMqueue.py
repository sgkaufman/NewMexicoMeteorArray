#!/usr/bin/env python

"""
FlushNMqueue.py (4720 bytes) 06-Apr, 2021
This script flushes the queue for files uploaded to New Mexico Meteor Array Server.

It is a hacked copy of 
Version 0.8 of file ExternalScript.py. Dated 03/25/2021. 
Byte count = 14564
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

def makeLogFile(log_file_dir="", prefix="", date_only=False):
    """
    Create a log file to provide as stdout and stderr for
    the subprocess.calls of the shell scripts.
    Return the file pointer to the log file in OPEN state.
    date_only means to only use the date in the log file name.
    """

    if date_only:
        format_str = '%Y_%m_%d'
    else:
        format_str = '%Y_%m_%d_%H%M%S.%f'

    log_filename = prefix + "_" + \
        datetime.datetime.utcnow().strftime(format_str) + ".log"

    full_filename = log_file_dir + log_filename
    print("Creating log file name %s\n" % full_filename)

    return full_filename

####################################

def getFilesAndUpload(logger, nm_config, log_file_fd):

    # The argument "log_file_fd" is assumed to be passed in
    # open state, and need not be closed during the call.

    logger.info('Starting the NM upload manager ...')

    # create the upload manager for the local files
    upload_manager = UploadManager(nm_config)
    upload_manager.start()

    # Begin the upload!
    upload_manager.uploadData()

    upload_manager.stop()


def uploadFiles( config, log_upload=True, log_script=False):
    """ Function to upload selected files from the ArchivedData or CapturedData
        directory to the New_Mexico_Server.
    """

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
        # Print out the arguments and variables of interest
        print ("Version 0.2 of FlushNMqueue.py, 06-Apr-2021, bytes = 4720", file=log_file)
        print("remote_dir set to %s" % remote_dir, file=log_file)
        print("Name of program running = %s" % (__name__), file=log_file)
        print("log_dir_name = %s" % log_dir_name, file=log_file)


        # logging needed when run as part of RMS, or when the argument is set
        # NOTE: When run as part of RMS, the program name is "FlushNMqueue".
        # Otherwise the program name is "__main__"
        if __name__ == "__main__" and log_upload:
            initLogging(config, "NM_UPLOAD_")
            # Get the logger handle. 
            log = logging.getLogger("logger.FlushNMqueue")
        else:
            log = logging.getLogger("logger")


        # Upload files to the NM Server
        getFilesAndUpload(log, nm_config, log_file)

    log.info("FlushNMqueue has finished!")

####################################

def str2bool(v):
    if isinstance(v, bool):
       return v
    if v.lower() in ('yes', 'true', '1'):
        return True
    elif v.lower() in ('no', 'false', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')

if __name__ == "__main__":

    nmp = argparse.ArgumentParser(description="""Flush the NM_Server upload queue""")
    
    nmp.add_argument('--log_script', type=str2bool, \
                     choices=[True, False, 'Yes', 'No', '0', '1'], \
                     default=False, \
                     help="When True, create a log file for the calls to TimeLapse.sh and BackuupToUSB.sh, and any others. When False, no log file is created."
                     )
    args = nmp.parse_args()

    config = RMS.ConfigReader.loadConfigFromDirectory(None, "/home/pi/source/RMS/.config")

    print("Running FlushNMqueue.py, 06-Apr, 2021, byte count = 4720, flushing the NM upload queue...")

    uploadFiles(config, log_upload=True, log_script=args.log_script)

####################################
