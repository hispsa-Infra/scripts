#!/bin/bash
# ---------------------------------------------------------------------------------------------------------------------------------
# Backup script for PostgreSQL databases to FTP server
# This script should be run once a day, presumably using a cron task
# Note: This script performs a daily AND weekly backup of ALL databases in PostgreSQL except the 'template' and 'postgres' schemas
#       to two separate FTP servers - to ensure Disaster Recovery in the event of loss of one server
# ---------------------------------------------------------------------------------------------------------------------------------
# *** IMPORTANT! ***
# Ensure that you have replaced the fields indicated below with actual values, as indicated by '<' and '>' enclosing brackets
# For example: <host_ip>, <ftp_users>, <ftp_pass's>, <ftp_dirs> and <encrypt_key>
# *** DO NOT FORGET THE ENCRYPTION KEY!! ***
# ---------------------------------------------------------------------------------------------------------------------------------
host_ip1="197.221.53.178"
host_ip2="197.189.224.68"
#host_ip3="197.221.53.178"
ftp_user1="dhis2"
ftp_pass1="D1V1p3jJ"
ftp_user2="dhis2"
ftp_pass2="gVWuF8DAsv"
#ftp_user3="public"
#ftp_pass3="CnWd7jMu"
ftp_dir1="$ftp_user1"
ftp_dir2="$ftp_user2"
#ftp_dir3="$ftp_user3"
backup_dir="/tmp"
encrypt_key="q8tEcBHwyQ"
weekly_backup="Friday"
dayinfo=`date '+%A'`
weekinfo=`date '+%V'`
dateinfo=`date '+%Y-%m-%d'`
logfile="$backup_dir/$(hostname -s)-$dateinfo-backup.log"
touch $logfile
databases=`psql --tuples-only -P format=unaligned -c "SELECT datname FROM pg_database WHERE NOT datistemplate AND datname <> 'postgres'";`
timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
{
	echo "$timeinfo > ---------------------------------------------------------------------"
    echo "$timeinfo >      HISP SOUTH AFRICA - Backup Script - Ver 2.2 - July 2016"
    echo "$timeinfo > ---------------------------------------------------------------------"
    sleep 3
    timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
    echo "$timeinfo > ** Starting Backup of databases **"
	for i in $databases; do
		timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
		echo "$timeinfo > Database: $i ---------------->"
		timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
        echo "$timeinfo >  - Vacuuming..."
		/usr/bin/vacuumdb -z $i
		timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
		echo "$timeinfo >  - Dumping..."
		/usr/bin/pg_dump -f $backup_dir/$i-ddb-$dayinfo.sql -T analytics* $i
		if [ "$dayinfo" == $weekly_backup ]; then
			timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
			echo "$timeinfo >  - (Weekly) Copy..."
			cp $backup_dir/$i-ddb-$dayinfo.sql $backup_dir/$i-wdb-Week$weekinfo.sql
		fi
		timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
		echo "$timeinfo >  - Pack/encrypting..."
		7z a -p$encrypt_key $backup_dir/$i-ddb-$dayinfo.7z $backup_dir/$i-ddb-$dayinfo.sql
		timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
		echo "$timeinfo >  - Uploading -> FTP1..."
		ftp-upload -h $host_ip1 -u $ftp_user1 -d $ftp_dir1 --password=$ftp_pass1 $backup_dir/$i-ddb-$dayinfo.7z
		timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
        echo "$timeinfo >  - Uploading -> FTP2..."
		ftp-upload -h $host_ip2 -u $ftp_user2 -d $ftp_dir2 --password=$ftp_pass2 $backup_dir/$i-ddb-$dayinfo.7z
        # Checks for an encrypted file on "public" FTP containing the location and connection details for a customer-specified copy of the backup
#        wget -q -P $backup_dir ftp://$ftp_user3:$ftp_pass3@$host_ip3/$ftp_dir3/$i-custom-backup.7z
#        if [ -f $backup_dir/$i-custom-backup.7z ]; then
#            timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
#            echo "$timeinfo >  - Custom FTP upload packfile found - Looking for encryption key..."
#            if [ -f /home/hisp/scripts/$i-encrypt.key ]; then
#                timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
#                echo "$timeinfo >    Encryption key found."
#                encrypt_custom=`cat /home/hisp/scripts/$i-encrypt.key`
#                timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
#                echo "$timeinfo >   Extracting custom FTP upload packfile..."
#                7z e -y -p$encrypt_custom $backup_dir/$i-custom-backup.7z
#                if [ -f $backup_dir/$i-custom-backup.txt ]; then
#                    while IFS="," read f1 f2 f3 f4; do
#                        timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
#                        echo "$timeinfo >  - Uploading -> Custom FTP..."
#                        ftp-upload -h $f1 -u $f2 -d $f4 --password=$f3 $backup_dir/$i-ddb-$dayinfo.7z
#                    done < $backup_dir/$i-custom-backup.txt
#                    rm $backup_dir/$i-custom-backup.7z
#               else
#                    timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
#                    echo "$timeinfo >  - WARNING: Custom FTP upload datafile not found!"
#                    echo "$timeinfo >    Unable to perform custom backup - skipping!"
#                fi
#            else
#                timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
#                echo "$timeinfo >  - ERROR: Encryption key not found!"
#                echo "$timeinfo >    Unable to perform custom backup - skipping!"
#            fi
#        else
#            timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
#            echo "$timeinfo >  - Custom FTP upload packfile not found!"
#            echo "$timeinfo >    Unable to perform custom backup - skipping!" 
#        fi
		if [ "$dayinfo" == $weekly_backup ]; then
			timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
			echo "$timeinfo >  - (Weekly) Pack/encrypt..."
			7z a -p$encrypt_key $backup_dir/$i-wdb-Week$weekinfo.7z $backup_dir/$i-wdb-Week$weekinfo.sql
			timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
			echo "$timeinfo >  - (Weekly) Uploading -> FTP1..."
			ftp-upload -h $host_ip1 -u $ftp_user1 -d $ftp_dir1 --password=$ftp_pass1 $backup_dir/$i-wdb-Week$weekinfo.7z
			timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
            echo "$timeinfo >  - (Weekly) Uploading -> FTP2..."
			ftp-upload -h $host_ip2 -u $ftp_user2 -d $ftp_dir2 --password=$ftp_pass2 $backup_dir/$i-wdb-Week$weekinfo.7z
            if [ -f $backup_dir/$i-custom-backup.txt ]; then
                while IFS="," read f1 f2 f3 f4; do
                    timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
                    echo "$timeinfo >  - Uploading -> Custom FTP..."
                    ftp-upload -h $f1 -u $f2 -d $f4 --password=$f3 $backup_dir/$i-wdb-Week$weekinfo.7z
                done < $backup_dir/$i-custom-backup.txt
                rm $backup_dir/$i-custom-backup.txt
            else
                timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
                echo "$timeinfo >  - ERROR: Custom FTP upload datafile not found!"
                echo "$timeinfo >    Unable to perform custom backup - skipping!"
            fi
		fi
		rm $backup_dir/$i-?db-*.*
        timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
        echo "$timeinfo > Database: $i Complete <<<<<"
        echo "$timeinfo >"
        echo "$timeinfo >"
	done
	timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
	echo "$timedateinfo > ** Complete Backup of databases **"
	echo "$timedateinfo > ---------------------------------------------------------------------"
} 2>&1 | tee $logfile
# Add code in here to verify backup file's upload has been successful - i.e. verify file(s) exist(s) on FTP1 and FTP2.
# Add code in here to send an email if the backup was NOT successful - i.e. the check above failed.
gzip -9 $logfile
ftp-upload -h $host_ip1 -u $ftp_user1 -d $ftp_dir1 --password=$ftp_pass1 $logfile.gz
ftp-upload -h $host_ip2 -u $ftp_user2 -d $ftp_dir2 --password=$ftp_pass2 $logfile.gz
rm $logfile.gz