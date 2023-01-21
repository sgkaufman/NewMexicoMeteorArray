import os
import argparse
import RMS.ConfigReader as cr
import iStream.iStream

if __name__ == "__main__":
    nmp = argparse.ArgumentParser(description="""Call the IstraStream external script, optionally giving it the directory name under CapturedFiles and ArchivedFiles. It will find the .config file, and use it, so that it is called just as it would be by RMS as an external script. That RMS call to its external script passes the arguments 'captured_night_dir', 'archived_night_dir', and 'config'. If the directory names are not passed, they are looked for, and the most recent are used.""")

    nmp.add_argument('--cdir', type=str, \
                     help="subdirectory of CapturedFiles with the most recent capture. For example, US0006_20220306_020833_56612.", \
                     default=None)
    nmp.add_argument('--adir', type=str, \
                     help="subdirectory of ArchivedFiles with the most recent capture data. For example, US0006_20220306_020833_56612.", \
                     default=None)
    nmp.add_argument('--config', type=str, nargs=1, metavar='CONFIG_PATH', \
                     help="Path to a config file which will be used in place of the default one.")
    args = nmp.parse_args()

    if args.cdir is None:
        
        # Now want to do the same thing as "find . -type d -print | sort -r",
        # and take the first line to get the most recent directory.
        c_dir=os.path.expanduser("~/RMS_data/CapturedFiles")
        print (c_dir, ":")
        print ( sorted( os.listdir(c_dir), reverse=True)[0] )

    if args.adir is None:
        a_dir = os.path.expanduser("~/RMS_data/ArchivedFiles")
        print (a_dir, ":")
        print (sorted ( os.listdir(a_dir), reverse=True)[0] )

    # Now get the config object.
    config = cr.loadConfigFromDirectory(args.config, os.path.abspath('${HOME}/source/RMS'))

    print ("config data :")
    print (config.stationID)

    # Now call iStream.py with args c_dir, a_dir, config

    iStream.iStream.rmsExternal(c_dir, a_dir, config)
