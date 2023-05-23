#!/usr/bin/python
import os, glob
import sys
import time
import traceback
import subprocess
import argparse
from RMS.ConfigReader import loadConfigFromDirectory

def rmsExternal(captured_night_dir, archived_night_dir, config):

    # Call Check_and_Clean.sh
    script_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Check_and_Clean.sh")

    command = [
            script_path,
            captured_night_dir,
            ]

    proc = subprocess.Popen(command)

    # Reboot the computer (script needs sudo priviledges, works only on Linux)
    time.sleep(20) # Sleep for 20 seconds to allow script to complete before reboot
    try:
        print ('Rebooting ...')
        os.system('sudo shutdown -r now')
    except Exception as e:
        print ('Exception! Not Rebooting ...')

#########################################################################

if __name__ == "__main__":

    nmp = argparse.ArgumentParser(description="""Run Error Checks and reboot the system after all processing.""")
    nmp.add_argument('--directory', type=str, \
                     help="Subdirectory of CapturedFiles or ArchiveFiles to upload. For example, US0006_20190421_020833_566122")
    nmp.add_argument('--config', type=str, \
                     default=os.environ['HOME'] + '/source/RMS', \
                     help="The full path to the directory containing the .config file for the camera. Defaults to the location on a Raspberry Pi RMS system.")

    args = nmp.parse_args()

    if args.directory is None:
        print ("Directory argument not present! Exiting ...")
        sys.exit()

    print ('directory arg: ', args.directory)
    print ('.config arg: ',   args.config)

    config = loadConfigFromDirectory('.', args.config)

    print("config.data_dir = ", config.data_dir)

    captured_data_dir = os.path.join(config.data_dir, 'CapturedFiles', args.directory)
    archived_data_dir = os.path.join(config.data_dir, 'ArchivedFiles', args.directory)

    rmsExternal(captured_data_dir, archived_data_dir, config)
