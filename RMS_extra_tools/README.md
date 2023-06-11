# RMS_extra_tools, 11-Jun, 2023

Error Check and File Cleanup utility: Check_and_Clean

    06/05/2023  02:30 AM             2,101 Check_and_Clean.py
    06/11/2023  02:33 PM             8,829 Check_and_Clean.sh
    06/05/2023  02:30 PM            35,823 LICENSE
    06/11/2023  02:35 PM             8,022 README.md

These RMS utility files can be used by RMS/GMN stations. They were written by Peter Eschman and Steve Kaufman, who are part of the New Mexico Meteor Array (NMMA). They enable error checking of  RMS/GMN data, and store the results in the <Station_ID>_Fits_Counts.txt file which is located in the ~/RMS_data directory. One new data line is added to the txt file each morning. This file is a very compact summary of station status, and can also be used to add notes manually regarding refocusing the camera, a new platepar file, or other details.

## Installing Check_and_Clean
To use these files, you need to either 
1. Call Check_and_Clean.py as an external script; or
2. If you are already using an external script, you need to add the call to Check_and_Clean.sh at the end of your existing script, just before the code to reboot the station.

### First Case: Adding an External Script for the first time.
If you are adding an external script for the first time, edit your .config file so it reads this way:

    ; External script
    ; An external script will be run after RMS finishes the processing for the night, it will be passed
 
    ; three arguments:
    ;   captured_night_dir, archived_night_dir, config - captured_night dir is the full path to the 
    ;   captured folder of the night, the second one is the archived, and config is an object holding 
    ;   the values in this config file.
    ; ---------------
    ; Enable running an external script at the end of every night of processing
    external_script_run: true
    ; Run the external script after auto reprocess. "auto_reprocess" needs to be "true" for this to work.
    auto_reprocess_external_script_run: true
    ; Full path to the external script
    external_script_path: /home/pi/source/RMS_extra_tools/Check_and_Clean.py
    ; Name of the function in the external script which will be called
    external_function_name: rmsExternal


    ; Daily reboot
    ; ---------------
    ; Reboot the computer daily after the processing and upload is done
    reboot_after_processing: false
    ; Name of the lock file which the external script should create to prevent rebooting until the 
    ;   script is done. The external script should remove this file if the reboot is to run after the 
    ;   script finishes. This file should be created in the config.data_dir directory (i.e. ~/RMS_data).

    reboot_lock_file: .reboot_lock

### Second Case: Calling from an existing external script
You may call the Check_and_Clean.sh bash script in two ways. 
The first does not support logging of results as Check_and_Clean.sh executes,
while the second one does support such logging.
Both are written in Python, as these code snippets are in the external script Python file.
It is important to note that the "captured_night_dir" is a full path to a directory
under the RMS_data/CapturedFiles directory. 
An example from a Pi4-based RMS system is

    /home/pi/RMS_data/CapturedFiles/US000N_20230605_024541_516553

#### No logging

    # Call Check_and_Clean.sh
    script_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Check_and_Clean.sh")

    command = [
            script_path,
            captured_night_dir
            ]

    proc = subprocess.Popen(command)

#### With logging

    # Call Check_and_Clean.sh
    script_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Check_and_Clean.sh")

    command = [
            script_path,
            captured_night_dir
            ]
     proc = subprocess.Popen(command,stdout=subprocess.PIPE)
     # Read Check_and_Clean.sh script output and append to log file
     while True:
        line = proc.stdout.readline()
        if not line:
            break
        log.info(line.rstrip().decode("utf-8"))

    exit_code = proc.wait()
    log.info('Exit status: {}'.format(exit_code))
    log.info(Check_and_Clean.sh script finished')

## Results of running Check_and_Clean.sh
Error checking is logged to the file ~/RMS_data/<StationID>_fits.counts.txt
The first line of the file should read:

Directory Name         # fits_files  # detections  Other Issues

Here are some typical data lines
    
    US000E_20230302_012710_534432: 4116	1 Only one Capture Directory! 31 GB free / 59 GB total
    US000E_20230303_012802_268331: 4103	54
    US000E_20230304_012856_358320: 4091	41
    US000E_20230305_012947_842752: 4078	23
    US000E_20230306_013037_127826: 4065	1  No Photometry, Clouded out?
    US000E_20230307_013130_000932: 4053	1  No Photometry, Clouded out?
    US000E_20230308_013218_762644: 4040	12
    US000E_20230309_013310_981482: 4027	10
    US000E_20230310_013400_766482: 4014	43
    US000E_20230311_013450_075548: 3999	4	-1 fits -0.2 min
    US000E_20230320_014219_338230: 3885	1  No Photometry, Clouded out?
    US000E_20230321_014308_622472: 3872	1  No Photometry, Clouded out?
    US000E_20230322_014357_170585: 3858	23
    US000E_20230323_014447_897819: 3845	1  No Photometry, Clouded out?
    US000E_20230324_014535_873013: 3832	27
    US000E_20230325_014627_146438: 3819	30

First the CapturedFiles data directory is listed, next the number of fits files found in that directory, next the number of detections reported in the filename of the detected stack, and finally, any other issues that are found. These other issues may include:
 - a shortfall in number of fits files captured or a warning if no fits files are recorded
 - a warning if the number of archived directories does not match the number of captured directories
 - a warning if the photometry file is missing, which may indicate a bad platepar
 - a warning if there is only one capture directory, which can indicate the storage drive is too full. In this case the total size of the data drive and amount of free space is reported 

The total capture duration time is used to calculate a maximum number of fits files that should be collected through the course of the night. This is done by dividing the capture duration in seconds by the time it takes to capture 255 video frames in a single fits file at a frame rate of 25 frames per second, which is 10.2 seconds. 
 duration_seconds / (255 / 25 = 10.2)

Because of a small amount of overhead as the system starts and stops capture, this calculated total typically overestimates by 4 fits files, so that number is subtracted before comparing to the number of fits files in the capture directory.

If your camera captures a different number of frames per second, you will have to adjust this section of Check_and_Clean.sh, located around line 84.

If the total fits files recorded is less than the corrected total a message is written to ~/RMS_data/<StationID>_fits.counts.txt showing the shortfall in file count and number of minutes of data that were missed.

In a few unusual cases where the system has rebooted during capture, the newest log file may be missing the capture duration log file line, in which case, the total number of expected fits files will be in error and an incorrect shorfall value may be reported.


As shown in the example above, other errors may be logged following the number of detected meteors.


At the end of the Check_and_Clean.sh script you can have the script clean out older files so there is more room to keep CapturedFiles directories. Sometimes it is important to have an older CapturedFiles directory available to extract data for a bolide that was too bright to be detected as a meteor.

This cleanup can be enabled or disabled by setting the variable CleanUp (around line 18 in the script) to either 1 or 0.
_________________________
