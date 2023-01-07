#!/usr/bin/env python

"""
This is Version 0.2 of file ExternalScript.py. Dated 12/08/2019.
PNE 12/08/2019: Added section at line 180 with call to BackupToUSB.sh

This is Version 0.1 of file ExternalScript.py. Dated 09/12/2019.
SGK 09/12/2019: Put all file finding and uploading into function
                 getFilesAndUpload(), and added fits_count.txt to upload.
SGK 09/09/2019: Call "sudo -r now" at the end of the script.
                Eliminate creation and removsl of .reboot_lock file.
                Assumes that "reboot_after_processing" in .config is false.
SGK 09/07/2019: Made creation of the .reboot_lock file the first thing done
                when uploadFiles is called.
This script 
1: Moves and/or copies files on the RMS stations, and 
2: Uploads files to the New Mexico Meteor Array Server.
"""

import os
import sys
import copy
import logging
import fnmatch
import argparse
import subprocess

import RMS.ConfigReader
from RMS.UploadManager import UploadManager
from RMS.Logger import initLogging
import ftplib
from ftplib import FTP_TLS

"""
Presets for upload configuration

Denis Vida
	
May 1, 2019, 1:07 PM (3 days ago)
	
to me, Peter
Hi Steve,
this sounds great!

I agree with everything, but I have a suggestion: instead of uploading all files of a given type, how about we offer some sort of presets? For example:
- 'full' - uploads everything that's uploaded in the tar file
- 'minimal' - uploads everything except FF files
- 'micro' - just uploads the config, FTPdetectinfo, CALSTARS and the platepar, without any graphs
- 'imgs' - only uploads the images and plots, no text files

We could also offer these upload modes for the main GMN upload, in case someone is running the station on a poor internet connection. I had an inquiry about installing one system on Antarctica where the connectivity is extremely poor.

Cheers,
Denis
"""
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

def getFilesAndUpload(logger, nm_config, main_data_dir):
    logger.info('Starting the NM upload manager ...')
    
    # create the upload manager for the local files
    upload_manager = UploadManager(nm_config)
    upload_manager.start()

    # Get the files from the main_data_dir for NM upload

    all_files = os.listdir(main_data_dir)

    png_files = findFiles(main_data_dir, all_files, "*.png")
    print("Adding %d png files to queue ..." % png_files.__len__())
    upload_manager.addFiles(png_files)
    
    jpg_files = findFiles(main_data_dir, all_files, "*.jpg")
    print("Adding %d jpg files to queue ..." % jpg_files.__len__())   
    upload_manager.addFiles(jpg_files)

    #ftp_files = findFiles(main_data_dir, all_files, "FTP*")
    #print("Adding %d ftp files to queue ..." % ftp_files.__len__())
    #upload_manager.addFiles(ftp_files)
    
    csv_files = findFiles(main_data_dir, all_files, "*.csv")
    print("Adding %d csv files to queue ..." % csv_files.__len__())
    upload_manager.addFiles(csv_files)
    
    cal_files = findFiles(main_data_dir, all_files, "*.cal")
    print("Adding %d cal files to queue ..." % cal_files.__len__())
    upload_manager.addFiles(cal_files)
    
    txt_files = findFiles(main_data_dir, all_files, "*.txt")
    print("Adding %d txt files to queue ..." % txt_files.__len__())
    upload_manager.addFiles(txt_files)
    
    #platepar_files = findFiles(main_data_dir, all_files, "platepar*.cal")
    #print("Adding %d platepar files to queue ..." % platepar_files.__len__())
    #upload_manager.addFiles(platepar_files)

    config_files = findFiles(main_data_dir, all_files, "/home/pi/source/RMS/.config")
    print("Adding %d config files to queue ..." % config_files.__len__())    
    upload_manager.addFiles(config_files)

    csv_dir = os.path.join(nm_config.data_dir, 'csv/')
    print("csv_dir set to %s" % csv_dir)

    fits_count_file = findFiles(csv_dir, os.listdir(csv_dir), \
                               "*fits_counts.txt")
    print("Adding %d fits_count.txt files to queue ..." % len(fits_count_file))
    upload_manager.addFiles(fits_count_file)
    
    # Get the .config file if the calibration file does not exist?

    # Begin the upload!
    
    upload_manager.uploadData()

    upload_manager.stop()


def uploadFiles(captured_night_dir, archived_night_dir, config, log_upload=True, which='A', preset='micro'):
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
    
    print("Name of program running = %s" % (__name__)  ) 
    if which == 'C':
        main_data_dir = captured_night_dir
    else:
        main_data_dir = archived_night_dir
        
    remote_dir = '/Users/meteorstations/Public'
    print("remote_dir set to %s" % remote_dir)
        
    nm_config = copy.copy(config)
    nm_config.stationID = 'meteorstations'
    nm_config.hostname = '10.8.0.61'
    nm_config.remote_dir = remote_dir
    # nm_config.data_dir = os.path.join(os.path.expanduser('~'), 'NM_data')
    # nm_config.log_dir = os.path.join(os.path.expanduser('~'), 'NM_data/logs')

    nm_config.upload_queue_file = 'NM_FILES_TO_UPLOAD.inf'

    # Start logging when run as part of RMS, or when the argument is set
    # NOTE: When run as part of RMS, the program name is "ExternalScript".
    # Otherwise the program name is "__main__"
    if __name__ == "__main__" and log_upload:
        initLogging(config, "NM_UPLOAD_")

    # Get the logger handle. 
    log = logging.getLogger("logger.ExternalScript")
    
    # print("About to call GenerateTimelapse.main()")
    # What is it about subprocess.call, with shell=True, that makes
    #         StartCapture execute? 
    # Utils.GenerateTimelapse.main(captured_night_dir)
    # print("Completed call to GenerateTimelapse.main()")

    dir_name = os.path.basename(captured_night_dir)
    
    status = subprocess.call("/home/pi/source/RMS/TimeLapse.sh " + dir_name, \
                             shell=True)

    # backup data to thumb drive, PNE 12/08/2019
    status = subprocess.call("/home/pi/source/RMS/BackupToUSB.sh " + dir_name, \
                             shell=True)

    # Upload files to the NM Server
    getFilesAndUpload(log, nm_config, main_data_dir)

    # Reboot the Pi. Code stolen from StartCapture.py.
    # (script needs sudo priviledges, works only on Linux)

    log.info('Rebooting now!')
    try:
        os.system('sudo shutdown -r now')

    except Exception as e:
        log.debug('Rebooting failed with message:\n' + repr(e))
        log.debug(repr(traceback.format_exception(*sys.exc_info())))

    
if __name__ == "__main__":

    nm_parser = argparse.ArgumentParser(description="""Upload files to New_Mexico_Server""")
    
    nm_parser.add_argument('--directory', type=str, \
                           help="Subdirectory of CapturedFiles or ArchiveFiles to upload. For example, US0006_20190421_020833_566122")
    nm_parser.add_argument('--which', type=str, choices=['C','A'], default='A',\
                           help="C for CapturedFiles, A for ArchivedFiles. A is default")
    nm_parser.add_argument('--preset', type=str, default='micro', \
                           choices=['full', 'minimal', 'micro', 'imgs'], \
                           help="which fileset to upload")
    args = nm_parser.parse_args()

    if args.directory == None:
        print ("Directory argument not present! Exiting ...")
        sys.exit()
 
    print ('directory arg: ', args.directory)
    print ('which arg: ', args.which)
    print ('preset arg: ', args.preset)

   
    config = RMS.ConfigReader.loadConfigFromDirectory(None, "/home/pi/source/RMS/.config")

    print("config.data_dir = ", config.data_dir)

    captured_data_dir = os.path.join(config.data_dir, 'CapturedFiles', args.directory)
    archive_data_dir = os.path.join(config.data_dir, 'ArchivedFiles', args.directory)
        
    uploadFiles(captured_data_dir, archive_data_dir, config, log_upload=True, preset='micro')



    
