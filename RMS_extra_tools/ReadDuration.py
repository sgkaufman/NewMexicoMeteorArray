#!/usr/bin/env python

import glob
import os
import re

def findNewestLogFile():
    logFiles = glob.glob('/home/pi/RMS_data/logs/*')
    numLogs = len(logFiles)
    newest = max(logFiles, key=os.path.getctime)
    print (f'{numLogs} log files; newest is {newest}')
    return newest


def getDurationFromLog(logFile):
    with open(logFile) as f:
        for line in f:
            if ('Waiting' in line):
                str = re.search('Waiting [:0-9\.]*', line)
                matched = str.group()
                beg = str.start()
                end = str.end()
                # print('Matched {} beginning at {}, ending at {}'.format(matched, beg, end))
                rest = line[end:-1]
                # print('Remainder of line is {}'.format(rest))
                dur = re.search('[0-9\.]+', rest)
                # print('Matched {} for duration'.format(dur))
                duration = dur.group()
                return duration

logFile = findNewestLogFile()
print('Newest log file is {}'.format(logFile))

duration = getDurationFromLog(logFile)
print('Duration: {}'.format(duration))

    

