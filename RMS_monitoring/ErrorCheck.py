#!/usr/bin/python
import os, glob
import sys
import traceback
import subprocess
import datetime
import logging
import argparse
from RMS.Logger import initLogging
from RMS.ConfigReader import loadConfigFromDirectory

def rmsExternal(captured_night_dir, archived_night_dir, config):
    initLogging(config, 'ExScript_')
    log = logging.getLogger("logger")
    log.info('External script started')

    # Call ErrorCheck.sh
    script_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "ErrorCheck.sh")
    log.info('Calling {}'.format(script_path))

    command = [
            script_path,
            captured_night_dir,
            ]

    proc = subprocess.Popen(command,stdout=subprocess.PIPE)

    # Read script output and append to log file
    while True:
        line = proc.stdout.readline()
        if not line:
            break
        log.info(line.rstrip().decode("utf-8"))

    exit_code = proc.wait()
    log.info('Exit status: {}'.format(exit_code))

    log.info('External script finished')
   

    # Reboot the computer (script needs sudo priviledges, works only on Linux)
    try:
        log.info("Rebooting system...")
        os.system('sudo shutdown -r now')
    except Exception as e:
        log.debug('Rebooting failed with message:\n' + repr(e))
        log.debug(repr(traceback.format_exception(*sys.exc_info())))

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
