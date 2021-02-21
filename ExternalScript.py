#!/usr/bin/env python

"""
This is Version 0.7 of file ExternalScript.py. Dated 02/20/2021. Intended for Python 3 on Buster-based Raspberry Pi4s.
SGK 02/20/2021: Changed argument types to bool, not int, in __main__, for
                --reboot, --CreateTimeLapse, and --CreateCaptureStack
SGK 02/01/2021: Added support for creating a stack of 
                the CapturedFiles FITS files. 
SGK 06/14/2020: Added Bluehost server 69.195.111.36 dedicated IP)
SGK 05/15/2020: Added computation of RMS.CaptureDuration for the night's
                start time and capture duration, needed for the FITS file
                creation watchdog.
SGK 03/22/2020: Added creation of a log file for the shell scripts
SGK 12/17/2019: 1. Added arguments "reboot" and "CreateTimeLapse"
                to uploadFiles and to the "__main__" call of ExternalScript.py.
                Both default to True. If reboot is True, RMS reboots at end of
                ExternalScript processing. Otherwise it does not.
                If CreateTimeLapse is True, the Timelapse.mp4 is created.
                Otherwise it is not.
                2. Normalized the syntax for determining length of lists in
                the function getFilesAndUpload.
                3. Added test for existence for file "Extra_Uploads.sh".
                If it exists, it gets executed.

This is Version 0.2 of file ExternalScript.py. Dated 12/08/2019.
PNE 12/08/2019: Added section at line 180 with call to BackupToUSB.sh

This is Version 0.1 of file ExternalScript.py. Dated 09/12/2019.
SGK 09/12/2019: Put all file finding and uploading into function
                 getFilesAndUpload(), and added fits_count.txt to upload.
SGK 09/09/2019: Call "sudo -r now" at the end of the script.
                Eliminate creation and removal of .reboot_lock file.
                Assumes that "reboot_after_processing" in .config is false.
SGK 09/07/2019: Made creation of the .reboot_lock file the first thing done
                when uploadFiles is called.
This script 
1: Moves and/or copies files on the RMS stations, and 
2: Uploads files to the New Mexico Meteor Array Server.
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

def makeLogFile(log_file_dir, prefix, time_arg=None):
    """
    Create a log file to provide as stdout and stderr for
    the subprocess.calls of the shell scripts.
    Return the file pointer to the log file in OPEN state.
    time_arg, if given, is a date string of the form
    "2020-05-20 02:33:45.123456". Cannot include a timezone at the end.
    """

    if time_arg is None:
        time_to_use = datetime.datetime.utcnow()
    else:
        time_to_use = datetime.datetime.fromisoformat(time_arg)

    log_filename = prefix + "_{0}_{1}_{2}".format \
        (time_to_use.year, \
         time_to_use.month, \
         time_to_use.day)
    full_filename = log_file_dir + log_filename
    print("Creating log file name %s\n" % full_filename)
    return full_filename

########################################################################
    
def findFiles(dataDir, allFiles, pattern):
    """
    Searches allFiles for those matching the pattern.
    allFiles is the list of files under dataDir,
    and dataDir is added to the names of the files matching pattern.
    Hence the list returned has all absolute path names.
    """
    found_files = []
    pattern_files = fnmatch.filter(allFiles, pattern)
    for pattern_file in pattern_files:
        full_file = os.path.join(dataDir, pattern_file)
        found_files.append(full_file)
    return found_files

def getFilesAndUpload(logger, nm_config, main_data_dir, log_file_fd):

    # The argument "log_file_fd" is assumed to be passed in
    # open state, and need not be closed during the call.
    
    logger.info('Starting the NM upload manager ...')
    
    # create the upload manager for the local files
    upload_manager = UploadManager(nm_config)
    upload_manager.start()

    # Get the files from the main_data_dir for NM upload

    all_files = os.listdir(main_data_dir)

    png_files = findFiles(main_data_dir, all_files, "*.png")
    print("Adding %d png files to queue ..." % len(png_files), file=log_file_fd)
    upload_manager.addFiles(png_files)
    
    jpg_files = findFiles(main_data_dir, all_files, "*.jpg")
    print("Adding %d jpg files to queue ..." % len(jpg_files), file=log_file_fd)   
    upload_manager.addFiles(jpg_files)

    #ftp_files = findFiles(main_data_dir, all_files, "FTP*")
    #print("Adding %d ftp files to queue ..." % ftp_files.__len__())
    #upload_manager.addFiles(ftp_files)
    
    csv_files = findFiles(main_data_dir, all_files, "*.csv")
    print("Adding %d csv files to queue ..." % len(csv_files), file=log_file_fd)
    upload_manager.addFiles(csv_files)
    
    cal_files = findFiles(main_data_dir, all_files, "*.cal")
    print("Adding %d cal files to queue ..." % len(cal_files), file=log_file_fd)
    upload_manager.addFiles(cal_files)
    
    txt_files = findFiles(main_data_dir, all_files, "*.txt")
    print("Adding %d txt files to queue ..." % len(txt_files), file=log_file_fd)
    upload_manager.addFiles(txt_files)
    
    #platepar_files = findFiles(main_data_dir, all_files, "platepar*.cal")
    #print("Adding %d platepar files to queue ..." % len(platepar_files), file=log_file_fd)
    #upload_manager.addFiles(platepar_files)

    config_files = findFiles(main_data_dir, all_files, "/home/pi/source/RMS/.config")
    print("Adding %d config files to queue ..." % len(config_files), file=log_file_fd)    
    upload_manager.addFiles(config_files)

    csv_dir = os.path.join(nm_config.data_dir, 'csv/')
    print("csv_dir set to %s" % csv_dir, file=log_file_fd)

    fits_count_file = findFiles(csv_dir, os.listdir(csv_dir), \
                               "*fits_counts.txt")
    print("Adding %d fits_count.txt files to queue ..." % len(fits_count_file), \
          file=log_file_fd)
    upload_manager.addFiles(fits_count_file)
    
    # Get the .config file if the calibration file does not exist?

    # Begin the upload!
    
    upload_manager.uploadData()

    upload_manager.stop()


def uploadFiles(captured_night_dir, archived_night_dir, config, log_upload=True, reboot=True, CreateTimeLapse=True, CreateCaptureStack=True, preset='micro'):
    """ Function to upload selected files from the ArchivedData or CapturedData
        directory to the New_Mexico_Server.
        Files to transfer include:
        *.jpg
        FTP*.txt
        *.png
        *.csv
        *.cal
        platepar*.cal
        .config (in case no platepar_cmn2010.cal)
    """

    # Variable definitions
    main_data_dir = archived_night_dir
    extra_uploads_file = "/home/pi/source/RMS/Extra_Uploads.sh"
    remote_dir = '/Users/meteorstations/Public'

    RMS_data_dir_name = os.path.abspath("/home/pi/RMS_data/")
    print ("RMS_data_dir_name = {0}".format(RMS_data_dir_name))
    data_dir_name = os.path.basename(main_data_dir)
    print ("data_dir_name = {0}".format(data_dir_name))
    log_dir_name = os.path.join(RMS_data_dir_name, 'logs/')
    print ("log_dir_name = {0}".format(log_dir_name))

    # Create the config object for New Mexico Meteor Array purposes
    nm_config = copy.copy(config)
    nm_config.stationID = 'meteorstations'
    nm_config.hostname = '10.8.0.61' # 69.195.111.36 for Bluehost
    nm_config.remote_dir = remote_dir
    nm_config.upload_queue_file = 'NM_FILES_TO_UPLOAD.inf'
    # nm_config.data_dir = os.path.join(os.path.expanduser('~'), 'NM_data')
    # nm_config.log_dir = os.path.join(os.path.expanduser('~'), 'NM_data/logs')

    # Compute and write out the next start time and capture time
    start_time, duration = captureDuration(config.latitude, \
                                           config.longitude, \
                                           config.elevation)
    duration_int = round(duration)
    time_str = start_time.isoformat(' ')
    print ("Time string is: {0}".format(time_str))
    time_file = makeLogFile(log_dir_name, "CaptureTimes", time_str)

    with open(time_file, 'w') as time_fd:
        print(time_str, file=time_fd)
        print(duration_int, file=time_fd)

    # Make and save the file descriptor for shell script and print function
    # calls. The "w+" mode ensures that the files is created if necessary.
    # The file remains open for writing until its "closed" method is called.

    log_file_name = makeLogFile(log_dir_name, "ShellScriptLog")
    with open(log_file_name, 'w+') as log_file:
        # Print out the arguments and variables of interest
        print("remote_dir set to %s" % remote_dir, file=log_file)
        print("Name of program running = %s" % (__name__), file=log_file)
        print("reboot arg = %s" % reboot, file=log_file)
        print("CreateTimeLapse arg = %s" % CreateTimeLapse, file=log_file)
        print("log_dir_name = %s" % log_dir_name, file=log_file)
        print("ArchivedFiles directory = %s" % archived_night_dir, \
              file=log_file)

        # What is it about subprocess.call, with shell=True, that makes
        # StartCapture execute? Or, at least some update checking
        # take place?

        # Prepare for calls to TimeLapse.sh,
        # second arg based on CreateTimeLapse,
        # third arg based on CreateCaptureStack.
        TimeLapse_cmd_str = "/home/pi/source/RMS/TimeLapse.sh " + data_dir_name
        if  CreateTimeLapse:
            TimeLapse_cmd_str = TimeLapse_cmd_str + " Yes"
        else:
            TimeLapse_cmd_str = TimeLapse_cmd_str + " No"

        if CreateCaptureStack:
            TimeLapse_cmd_str = TimeLapse_cmd_str + " Yes"
        else:
            TimeLapse_cmd_str = TimeLapse_cmd_str + " No"
            
        print("TimeLapse_cmd_str = ", TimeLapse_cmd_str, file=log_file)
        status = subprocess.call(TimeLapse_cmd_str, \
                                 stdout=log_file, \
                                 stderr=log_file, \
                                 shell=True)
        print("TimeLapse call returned with status ", \
              status, file=log_file)
    
        # backup data to thumb drive, PNE 12/08/2019
        status = subprocess.call("/home/pi/source/RMS/BackupToUSB.sh " \
                                 + data_dir_name, \
                                 stdout=log_file, \
                                 stderr=log_file, \
                                 shell=True)
        print("BackupToUSB call returned with status ", \
              status, file=log_file)

        # logging needed when run as part of RMS, or when the argument is set
        # NOTE: When run as part of RMS, the program name is "ExternalScript".
        # Otherwise the program name is "__main__"
        if __name__ == "__main__" and log_upload:
            initLogging(config, "NM_UPLOAD_")
            # Get the logger handle. 
            log = logging.getLogger("logger.ExternalScript")
        else:
            log = logging.getLogger("logger")

                    
        # Upload files to the NM Server
        getFilesAndUpload(log, nm_config, main_data_dir, log_file)

        # Test for existence of "Extra_Uploads.sh".
        # Execute it if it exists.

        if (os.path.exists(extra_uploads_file)):
            status = subprocess.call(extra_uploads_file, \
                                     stdout=log_file, \
                                     stderr=log_file, \
                                     shell=True)
            print(extra_uploads_file, " executed with status ", \
                  status, file=log_file)
        else:
            print("No ", extra_uploads_file, " found to execute", \
                  file=log_file)

    # Reboot the Pi if requested. Code stolen from StartCapture.py.
    # (script needs sudo priviledges, works only on Linux)

    if __name__ == "__main__" and log_upload:
        initLogging(config, "NM_UPLOAD_")

    if reboot:
        log.info('Rebooting now!')
        try:
            os.system('sudo shutdown -r now')

        except Exception as e:
            log.debug('Rebooting failed with message:\n' + repr(e))
            log.debug(repr(traceback.format_exception(*sys.exc_info())))

########################################################################

if __name__ == "__main__":

    
    nm_parser = argparse.ArgumentParser(description="""Upload files to New_Mexico_Server, and optionally move other files to storage devices, create a TimeLapse.mp4 file, and reboot the system after all processing.""")
    
    nm_parser.add_argument('--directory', type=str, \
                           help="Subdirectory of CapturedFiles or ArchiveFiles to upload. For example, US0006_20190421_020833_566122")
    nm_parser.add_argument('--reboot', type=bool, choices=[True, False], \
                           default=True,\
                           help="When True, reboot at end of ExternalScript. False Prevents reboot. Default is True.")
    nm_parser.add_argument('--CreateTimeLapse', type=bool, choices=[True,False],\
                           default=True,\
                           help="When True, create the TimeLapse.mp4 file. False prevents creation. Default is True")
    nm_parser.add_argument('--CreateCaptureStack', type=bool, choices=[True,False],\
                           default=True,\
                           help="When True, create the stack of all Captures in a JPEG file. False prevents creation. Default is True")
    nm_parser.add_argument('--preset', type=str, default='micro', \
                           choices=['full', 'minimal', 'micro', 'imgs'], \
                           help="which fileset to upload")
    args = nm_parser.parse_args()

    if args.directory == None:
        print ("Directory argument not present! Exiting ...")
        sys.exit()
 
    print ('directory arg: ', args.directory)
    print ('Reboot arg: ', args.reboot)
    print ('CreateTimeLapse arg: ', args.CreateTimeLapse)
    print ('CreateCaptureStack arg: ', args.CreateCaptureStack)
    print ('preset arg: ', args.preset)

   
    config = RMS.ConfigReader.loadConfigFromDirectory(None, "/home/pi/source/RMS/.config")

    print("config.data_dir = ", config.data_dir)

    captured_data_dir = os.path.join(config.data_dir, 'CapturedFiles', args.directory)
    archive_data_dir = os.path.join(config.data_dir, 'ArchivedFiles', args.directory)
    
    uploadFiles(captured_data_dir, archive_data_dir, config, \
                log_upload=True, \
                reboot=args.reboot, \
                CreateTimeLapse=args.CreateTimeLapse, \
                CreateCaptureStack=args.CreateCaptureStack, \
                preset='micro')



    
