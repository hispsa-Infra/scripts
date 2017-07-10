#!/bin/bash
# --------------------------------------------------------------------------------------------------------------------------------- Script to rotate logs on all Tomcat instances, acording to variables passed to the script 
# This script is designed to be run on command, but can also be included in cron tasks to have regular runs, ideally every hour.
#
# --------------------------------------------------------------------------------------------------------------------------------- Check that all required variables have been passed; if not, exit with usage or help text. 
#Variables
temp_folder="/tmp"
zip_type=".gz"
compress_level=$2
size=$3
tomcat_id="tomcat"
remote_host="197.221.53.178"
remote_user="dump"
remote_password="u0JMFV6s"
remote_dir="dump/renier/rotate"
#Cleanup and parse variables
temp_folder=${temp_folder%/}
#This for-loop list all the folders that are in the home folder (the default place for installing web-servers)
folders=(~/*)
for ((i=0; i<${#folders[@]}; i++)); do
	#For each folder we check for the tomcat_id phrase to identify which are the webservers.
	if [[ ${folders[$i]} == *"$tomcat_id"* ]]
	then
		#echo "Current Tomcat Folder = "${folders[$i]}
		#For Loop Variables
		tomcat=${folders[$i]}
		log=$tomcat/logs/catalina.out
		#Locate the Tomcat dhis2 log file.
                if [ -e $tomcat/conf/dhis.conf ]
		then
			config="$tomcat/conf/dhis.conf"
		elif [ -e $tomcat/conf/hibernate.properties ]
		then
			config="$tomcat/conf/hibernate.properties"
		else
			echo "This logration cannot happen because the dhis2 configuration file cannot be found!"
			#Bunch of other things that need doing put here; for example, exit with an error code or email a fault report. I would suggest continuing with the log rotation, but attempt to log an error so that it 
			#can be mailed by the cron job once this script is complete. Successful log rotations should not be included in the error/mail/log...  should they?  I vote not.  We should discuss. NOTE: WE MAY WANT 
			#TO LOGROTATE TOMCATS THAT ARE NOT DHIS2 SYSTEMS, SO MAYBE WE SHOULD LOOK FOR A CATALINA.OUT ANYWAY?
		fi
		#Craft the logfile name, based on dbname in config file.  Drop the Carriage return at the end of the datafile variable.
		datafile=$(awk '/3447/ {print $3;}' $config | cut -d '/' -f 4)
		#echo "before = "$datafile
		echo $datafile > /tmp/tmp.rotate.dat
		tr -cd [:print:]  < /tmp/tmp.rotate.dat > /tmp/tmp.rotate.dat2
		datafile=$(< /tmp/tmp.rotate.dat2)
		#echo "datafile = "$datafile
		file_date=$(date +"%Y-%m-%d")
		#echo "file_date = "$file_date
		#The sequencing needs to be done - it must be tied to the secdual - the WHAAT? I can't make that one out...  ;-) Sequencing needs to be iterative starting from nothing, then -1, then -2, etc.
		file_sequence=$(date +"%H")
		#echo "file_sequence = "$file_sequence
		output_file=${datafile}'_'$file_date'_'$file_sequence'.log'
		echo "output_file = "$output_file
		output_zipped=$output_file$zip_type
		#echo "output_zipped = "$output_zipped
		#copy the current content of the log file to a file that will be uploaded.
		echo 'log copy command'
		cat $log >> $temp_folder/$output_file
		#Clears the log file without locking or recreating it.
		#echo 'log Clearing Command'
		truncate -s 0 $log
		#Add a header to the log file to note the name of the preceding file.
		#echo 'log header'
		echo "Log Continued from $output_file" > $log
		#Zip the log file for easy movement
		#echo 'Zip Comand'
		gzip -9 $temp_folder/$output_file
		#Upload the output_file of the log file to the ftp
		#echo 'Zip Command'
		ftp-upload -h $remote_host -u $remote_user --password=$remote_password -d $remote_dir $temp_folder/$output_zipped
		#Cleaning temp output folder
		#echo 'Clear Command'
		rm $temp_folder/$output_zipped
	fi done
