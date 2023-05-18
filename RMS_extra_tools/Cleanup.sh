#!/bin/bash

printf "Cleanup.sh 17-May, 2023, byte count 1153: clean out older data\n"
# set variables adirs, cdirs, and older to 0 to skip cleanups

# delete older ArchivedFiles directories
adirs=10

# delete older CapturedFiles directories
cdirs=10

# delete older tar.bz2 archives
older=10

# delete older log files
logs=21

cd "$HOME"/RMS_data/ArchivedFiles

if (adirs -gt 0)
   printf "Deleting ArchivedFiles directories more than %s days old\n" "${adirs}"
   adirs=$((adirs-1))
   find -mtime +$adirs -type d | xargs rm -f -r
fi

if (older -gt 0)
   printf "Deleting tar.bz2 files more than %s days old\n" "${older}" 
   older=$((older-1))
   find "$HOME"/RMS_data/ArchivedFiles/*.bz2 -type f -mtime +$older -delete;
fi

if (cdirs -gt 0)
   cd "$HOME"/RMS_data/CapturedFiles
   printf "Deleting CapturedFiles directories more than %s days old\n" "${cdirs}"
   cdirs=$((cdirs-1))
   find -mtime +$cdirs -type d | xargs rm -f -r 
fi

if (logs -gt 0)
   printf "Deleting files in RMS_data/logs more than %s days old\n" "$(logs)"
   logs=$((logs-1))
   find "$HOME"/RMS_data/logs/ -type f -mtime +$logs -delete;
fi

printf "Done deleting old data\n "
