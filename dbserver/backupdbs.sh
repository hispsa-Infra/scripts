#!/bin/bash
host_ip1="197.221.53.178"
ftp_user1="dhis2"
ftp_pass1="D1V1p3jJ"
ftp_dir1="$ftp_user1"
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
	echo "---------------------------------------------------------------------"
    echo "      HISP SOUTH AFRICA - Backup Script - Ver 2.3 - October 2016"
    echo "---------------------------------------------------------------------"
	echo ""
    timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
    echo "$timeinfo > ** Starting Backup of databases **"
	timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
	echo "$timeinfo > Step 1: Starting dump of databases"
	for i in $databases; do
		timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
		echo "$timeinfo > Database: $i ---------------->"
		timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
        echo "$timeinfo >  - Vacuuming..."
		/usr/bin/vacuumdb -z $i
		timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
		echo "$timeinfo >  - Dumping..."
		/usr/bin/pg_dump -f $backup_dir/$i-ddb-$dayinfo.sql -T analytics* $i
		timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
        echo "$timeinfo > Dump: $i Complete <----------------"
	done
	timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
	echo "$timeinfo > Step 2: Starting pack/encryption of databases"
	for i in $databases; do
		timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
		echo "$timeinfo >  - Pack/encrypting $i ---------------->"
		7z a -mx=1 -p$encrypt_key $backup_dir/$i-ddb-$dayinfo.7z $backup_dir/$i-ddb-$dayinfo.sql
		if [ "$dayinfo" == $weekly_backup ]; then
			timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
			echo "$timeinfo >  - (Weekly) Copy..."
			cp $backup_dir/$i-ddb-$dayinfo.sql $backup_dir/$i-wdb-Week$weekinfo.sql
		fi
		timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
        echo "$timeinfo > Pack: $i Complete <----------------"
	done
	timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
	echo "$timeinfo > Step 3: Upload of databases"
	for i in $databases; do
		timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
		echo "$timeinfo >  - Uploading: $i ---------------->"
		ftp-upload -h $host_ip1 -u $ftp_user1 -d $ftp_dir1 --password=$ftp_pass1 $backup_dir/$i-ddb-$dayinfo.7z
		if [ "$dayinfo" == $weekly_backup ]; then
			timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
			echo "$timeinfo >  - (Weekly) Pack/encrypt..."
			7z a -mx=1 -p$encrypt_key $backup_dir/$i-wdb-Week$weekinfo.7z $backup_dir/$i-wdb-Week$weekinfo.sql
			timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
			echo "$timeinfo >  - (Weekly) Uploading -> FTP1..."
			ftp-upload -h $host_ip1 -u $ftp_user1 -d $ftp_dir1 --password=$ftp_pass1 $backup_dir/$i-wdb-Week$weekinfo.7z
			timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
		fi
		rm $backup_dir/$i-?db-*.*
        timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
        echo "$timeinfo > Upload: $i Complete <----------------"
        echo ""
        sleep 3
	done
	timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
	echo "$timedateinfo > ** Complete Backup of databases **"
	echo "$timedateinfo > ---------------------------------------------------------------------"
} 2>&1 | tee $logfile
gzip -9 $logfile
ftp-upload -h $host_ip1 -u $ftp_user1 -d $ftp_dir1 --password=$ftp_pass1 $logfile.gz
rm $logfile.gz