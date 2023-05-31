#!/bin/bash

# Could take an integer argument of the number of files to leave
# in the ~/RMS_data/CapturedFiles directory. Now that's set in the
# variable $dirs_to_keep

declare -i dirs_to_keep=10
declare -a dir_array

dir_len=$(find ${HOME}/RMS_data/CapturedFiles -maxdepth 1 -type d -name 'US*' | wc -l)

printf "Number directories: %d\n" ${dir_len}

dir_array=($(find ${HOME}/RMS_data/CapturedFiles -maxdepth 1 -type d -name 'US*' | sort -r))

for ((i=0; i<dir_len; i++)); do
    #printf "%d: %s\n" $i ${dir_array[i]}
    if [[ $i -gt $dirs_to_keep-1 ]]; then
	printf "Will remove directory %s\n" ${dir_array[i]}
    else
	printf "Will keep directory %s\n" ${dir_array[i]}
    fi
done


