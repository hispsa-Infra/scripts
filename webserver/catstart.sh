
#!/bin/bash
# ---------------------------------------------------------------------------------------------------------------------------------
# Script to start all Tomcat instances on the local server, in staggered array
# This script should be run on command, usually only just after a reboot/restart of the server
# Note: This script performs a startup of each instance, separated by a timed window; this is normal, and intended
#       to ensure that global variables in use during startup don't interfere, as well as reduce instant load.
# ---------------------------------------------------------------------------------------------------------------------------------
temp_dir="/tmp"
dateinfo=`date '+%Y-%m-%d'`
logfile="$temp_dir/$(hostname -s)-$dateinfo-catstart.log"
touch $logfile
startups=$( find | egrep startup | grep sh )
timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
{
	echo "$timeinfo > ---------------------------------------------------------------------"
    echo "$timeinfo >      HISP SOUTH AFRICA - CatStart Script - Ver 2.1 - May 2015"
    echo "$timeinfo > ---------------------------------------------------------------------"
    sleep 3
    timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
    echo "$timeinfo > ** Starting all local Tomcat instances **"
    for i in $startups; do
        timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
        echo "$timeinfo > Instance:----------------> $i"
        $i
        timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
        echo "$timeinfo > Waiting for startup... - please stand by."
        sleep 20
        timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
        echo "$timeinfo > ..."
        sleep 20
        timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
        echo "$timeinfo > ..."
        sleep 20
        timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
        echo "$timeinfo > ..."
    done
	timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
	echo "$timeinfo > ** All Tomcats started **"
	echo "$timeinfo > ---------------------------------------------------------------------"
} 2>&1 | tee $logfile