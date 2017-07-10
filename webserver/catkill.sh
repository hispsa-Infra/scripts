#!/bin/bash
# ---------------------------------------------------------------------------------------------------------------------------------
# Script to shutdown all Tomcat instances on the local server, in staggered array
# This script should be run on command, usually only just before a reboot/restart of the server
# Note: This script performs a double-shutdown of each instance, separated by a timed window; this is normal, and intended
#       to clear (properly) any variables in use by Java/Tomcat on the system in question.
# ---------------------------------------------------------------------------------------------------------------------------------
temp_dir="/tmp"
dateinfo=`date '+%Y-%m-%d'`
logfile="$temp_dir/$(hostname -s)-$dateinfo-catkill.log"
touch $logfile
shutdowns=$( find | egrep shutdown | grep sh )
timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
{
	echo "$timeinfo > ---------------------------------------------------------------------"
    echo "$timeinfo >      HISP SOUTH AFRICA - CatKill Script - Ver 2.1 - May 2015"
    echo "$timeinfo > ---------------------------------------------------------------------"
    sleep 3
    timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
    echo "$timeinfo > ** Shutting down all local Tomcat instances **"
    for i in $shutdowns; do
        timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
        echo "$timeinfo > Instance:----------------> $i"
        $i
        sleep 1
        $i
        sleep 1
    done
	timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
	echo "$timeinfo > ** All Tomcats shut down **"
	echo "$timeinfo > ---------------------------------------------------------------------"
} 2>&1 | tee $logfile