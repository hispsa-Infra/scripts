#!/bin/bash
# ---------------------------------------------------------------------------------------------------------------------------------
# Quick Dump script for PostgreSQL databases to FTP server
# This script should be run on command, just prior to a Change
# Note: This script performs a quick backup ("dump") of all local databases to the /tmp folder and an FTP dump folder
#       for the purposes of performing a Change Control.  Note that encryption is NOT used; backups should be wiped after
#       a successful Change.  Also note that all files in the /tmp folder are wiped on system restart.
# ---------------------------------------------------------------------------------------------------------------------------------
host_ip1="197.221.53.178"
ftp_user1="dump"
ftp_pass1="u0JMFV6s"
ftp_dir1="$ftp_user1"
backup_dir="/tmp"
dayinfo=`date '+%A'`
weekinfo=`date '+%V'`
dateinfo=`date '+%Y-%m-%d'`
logfile="$backup_dir/$(hostname -s)-$dateinfo-dump.log"
touch $logfile
databases=`psql --tuples-only -P format=unaligned -c "SELECT datname FROM pg_database WHERE NOT datistemplate AND datname <> 'postgres'";`
timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
{
	echo "$timeinfo > ---------------------------------------------------------------------"
    echo "$timeinfo >      HISP SOUTH AFRICA - Dump Script - Ver 2.1 - May 2015"
    echo "$timeinfo > ---------------------------------------------------------------------"
    sleep 3
    timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
    echo "$timeinfo > ** Starting Dump of databases **"
	for i in $databases; do
		timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
		echo "$timeinfo > Database:----------------> $i"
        timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
		echo "$timeinfo >  - Dumping..."
		/usr/bin/pg_dump -f $backup_dir/$i-dump-$dateinfo.sql -T analytics* $i
		timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
		echo "$timeinfo >  - Packing..."
		gzip -9 $backup_dir/$i-dump-$dateinfo.sql
        timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
		echo "$timeinfo >  - Uploading -> Dump FTP..."
		ftp-upload -h $host_ip1 -u $ftp_user1 -d $ftp_dir1 --password=$ftp_pass1 $backup_dir/$i-dump-$dateinfo.sql.gz
        timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
        echo "$timeinfo > Database: $i Complete <<<<<"
        echo "$timeinfo >"
        echo "$timeinfo >"
	done
	timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
	echo "$timeinfo > ** Complete Dump of databases **"
	echo "$timeinfo > ---------------------------------------------------------------------"
} 2>&1 | tee $logfile