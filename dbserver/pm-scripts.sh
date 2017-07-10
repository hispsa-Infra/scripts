#!/bin/bash
# ---------------------------------------------------------------------------------------------------------------------------------
# Custom script for running user/customer PostgreSQL scripts against databases on an automated basis
# This script should be run once a day, presumably using a cron task - in particular, this one is for the morning
# WARNING: This script does NOT verify a script's nature before running it; it is assumed that any scripts uploaded by the users
#          or customers are assumed to have been verified already!  (Presumably, by running them against Staging copied from Live)
# ---------------------------------------------------------------------------------------------------------------------------------
host_ip1="197.221.53.178"
host_ip2="197.189.224.82"
host_ip3="197.221.53.178"
ftp_user1="dhis2"
ftp_pass1="D1V1p3jJ"
ftp_user2="dhis2"
ftp_pass2="d2Yimk7q"
ftp_user3="public"
ftp_pass3="CnWd7jMu"
ftp_dir1="$ftp_user1"
ftp_dir2="$ftp_user2"
ftp_dir3="$ftp_user3"
working_dir="/tmp"
dayinfo=`date '+%A'`
weekinfo=`date '+%V'`
dateinfo=`date '+%Y-%m-%d'`
logfile="$working_dir/$(hostname -s)-$dateinfo-am-scripts.log"
touch $logfile
databases=`psql --tuples-only -P format=unaligned -c "SELECT datname FROM pg_database WHERE NOT datistemplate AND datname <> 'postgres'";`
timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
{
	echo "$timeinfo > ---------------------------------------------------------------------"
    echo "$timeinfo >     HISP SOUTH AFRICA - PM Scripts Script - Ver 2.1 - May 2015"
    echo "$timeinfo > ---------------------------------------------------------------------"
    sleep3
    timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
    echo "$timeinfo > ** Starting Morning(AM) scripts **"
	for i in $databases; do
		timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
		echo "$timeinfo > Database: $i ---------------->"
        wget -q -P $working_dir ftp://$ftp_user3:$ftp_pass3@$host_ip3/$ftp_dir3/$i-am-scripts.7z
        if [ -f $working_dir/$i-am-scripts.7z ]; then
            timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
            echo "$timeinfo >  - Custom AM script packfile found - Looking for encryption key..."
            if [ -f /home/hisp/scripts/$i-encrypt.key ]; then
                timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
                echo "$timeinfo >    Encryption key found."
                encrypt_custom=`cat /home/hisp/scripts/$i-encrypt.key`
                timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
                echo "$timeinfo >   Extracting custom AM script packfile..."
                7z e -p$encrypt_custom $working_dir/$i-am-scripts.7z
                if [ -f $working_dir/$i-am-scripts.txt ]; then
                    while IFS="," read f1 f2 f3 f4; do
                        timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
                        echo "$timeinfo >   Running script $f1..."
                        psql -f $working_dir/$f1 $i
                        sleep 1
                        rm $working_dir/$f1
                    done < $working_dir/$i-am-scripts.txt
                    rm $working_dir/$i-am-scripts.txt
                else
                    timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
                    echo "$timeinfo >  - ERROR: Custom AM script datafile not found!"
                    echo "$timeinfo >    Unable to perform custom AM scripts - skipping!"
                fi
            else
                timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
                echo "$timeinfo >  - ERROR: Encryption key not found!"
                echo "$timeinfo >    Unable to perform custom AM scripts - skipping!"
            fi
            rm $working_dir/$i-am-scripts.7z
        else
            timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
            echo "$timeinfo >  - Custom AM script packfile not found!"
            echo "$timeinfo >    Unable to perform custom AM scripts - skipping!"
        fi
        timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
        echo "$timeinfo > Database: $i Complete <<<<<"
        echo "$timeinfo >"
        echo "$timeinfo >"
    done
	timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
	echo "$timedateinfo > ** Completed Morning(AM) scripts **"
	echo "$timedateinfo > ---------------------------------------------------------------------"
} 2>&1 | tee $logfile
gzip -9 $logfile
ftp-upload -h $host_ip1 -u $ftp_user1 -d $ftp_dir1 --password=$ftp_pass1 $logfile.gz
ftp-upload -h $host_ip2 -u $ftp_user2 -d $ftp_dir2 --password=$ftp_pass2 $logfile.gz
rm $logfile.gz