#!/bin/bash
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# --------------  HISP South Africa - Customisation Script for web-DHIS/DHIS2 instances.  ---------------------------------------------------------------------------------------------
# This script uses a configuration file with a set series of variables to alter the login.css file located in the /web-dhis-commons/ folder of an unpacked Tomcat-based dhis war file.
# Usage: This script can be run once-off, but is also designed to be used in a cron job to ensure that new deployments are automatically updated/refreshed/customised.
# Notes: No variables passed.  All variables and configuration is done inside the customise.conf file, which should be located in the ~/custom folder, along with any images.
# Syntax: /home/hisp/scripts/customise.sh
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

temp_dir="/tmp"
#instantiate and update the logfile
logfile="$temp_dir/$(hostname -s)-$dateinfo-customise.log"
timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
touch $logfile
{
	echo "$timeinfo > ---------------------------------------------------------------------"
	echo "$timeinfo >    HISP SOUTH AFRICA - Customisation Script - Ver 2.2 - May 2017"
	echo "$timeinfo > ---------------------------------------------------------------------"
	#build an array containing all the 'customise.conf' files found on this system
	custom_conf=($(locate customise.conf | grep -v 'backup' | grep -v 'swp'))
	if [ ! -r $custom_conf ]; then
                #TODO Error handling here - the line returned a value not handled by any previous section.
                echo "Error!"
                echo "The customise.conf file cannot be found!  Unable to proceed.  Looking for:"
                echo $custom_conf
                exit
	fi
	#locate the folder path where custom conf is stored; used later to copy/replace images
	custom_folder=($(dirname $custom_conf))
	#build an array containing all the 'login.css' files found on this system
	css_files=($(locate login.css | grep 'tomcat8-dhis2' | grep -v 'swp'))
	#if the customise.conf file is found, then
	if [ -r $custom_conf ]; then
		#build an array of the war files found on this system; limit them to containing the phrase 'tomcat8-dhis2', so we know they are actual instances
		instances=$(locate *.war | grep tomcat8-dhis2)
		#parse the customise.conf file into an array
		readarray arr1 < $custom_conf
		#step through the array arr1
		for str1 in "${arr1[@]}"; do
			#set three flags for the purposes of tracking each varibale, whether the corresponding instance is found,
			#  and if so, the corresponding variable is identified/located, and then finally whther the value is updated
			var_flag_no=0
			var_flag_name=0
			var_flag_value=0
			#in arr1 exclude lines beginning with '#' - comments or lines of length 1 char (line feed or carriage return)
			#by echoing them into null
			if [[ $str1 == '#'* || ${#str1} == 1 ]]; then
				echo > /dev/null
			#in arr1 include lines longer than 1 character.
			elif [[ ${#str1} > 1 ]]; then
				#get the first segment of the str1 (which is the tomcat instance number/character identifying the instance)
				#for which the following variables apply
				var_no=$(echo $str1 | awk -F '|' '{print $1;}')
                                #get the second and third segment of the str1, which are the variables we need to find and set
                                var_name=$(echo $str1 | awk -F '|' '{print $2;}')
                                var_value=$(echo $str1 | awk -F '|' '{print $3;}')
                                #step through the css_files array
				for str2 in "${css_files[@]}"; do
					#extract the instance folder for each css file found
					css_no=$(echo $str2 | awk -F '/' '{print $(NF-5);}')
					#count the characters in the extracted string
					sum_chr_css_no=${#css_no}
					#update the css_number variable to the last character in the folder string; arriving at the number/char
					#identifying the instance to which the css file belongs
					css_no=${css_no:($sum_chr_css_no-1):1}
					#if the css_number and var_number are the same, then the instance corresponding to the conf
					#variable exists; we thus need to execute the update/change
					if [[ $var_no == $css_no ]]; then
						#update the log file and announce action
						css_file=$(basename $str2)
						war_file=$(echo $str2 | awk -F '/' '{print $(NF-3);}')
						timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
                                                echo "$timeinfo Instance: $war_file Updating: $css_file Value: $var_name -> $var_value"
                                                #read the css file into an array (arr2) so we can determine the current variable in the case
						#  statement below
                                                readarray arr2 < $str2
                                                #execute a sed based on the name of the variable being passed
						case $var_name in
							html_body_background_color)
								#replace the background_color under html,body section
								sed  -i "\|html,body| {N;N;s|background-color: .*;|background-color: $var_value;|}" $str2
								;;
							html_body_color)
								#count our position in the array arr2
								count_arr2=0
								#for each entry in the arr2 array, do
								for str3 in "${arr2[@]}"; do
									#check if the entry corresponds to the html,body header
									if [[ $str3 == "html,body"* ]]; then
										#jump down three lines (i.e. skip forward three entries in arr2)
										str4="${arr2[($count_arr2+3)]}"
										#update str4 (trim it) to just the color value
										str4=$(echo $str4 | awk -F ' ' '{print $2;}')
										#replace the color value found with the conf file value
										sed  -i "\|html,body| {N;N;N;s|color: $str4|color: $var_value;|}" $str2
										#if this executes then stop looping through arr2
										break
									fi
									#if html,body not found look at the next arr2 entry
									count_arr2=($count_arr2+1)
								done
								;;
							a_color)
                                                                #count our position in the array arr2
                                                                count_arr2=0
                                                                #for each entry in the arr2 array, do
                                                                for str3 in "${arr2[@]}"; do
                                                                        #check if the entry is a open curly below an "a" header
                                                                        if [[ $str3 == "{"* && "${arr2[($count_arr2-1)]}" == "a"* ]]; then
                                                                                #jump down one line (i.e. skip forward one entry in arr2)
                                                                                str4="${arr2[($count_arr2+1)]}"
                                                                                #update str4 (trim it) to just the color value
                                                                                str4=$(echo $str4 | awk -F ' ' '{print $2;}')
                                                                                #replace the color value found with the conf file value
                                                                                sed  -i "\|a| {N;N;s|color: $str4|color: $var_value;|}" $str2
                                                                                #if this executes then stop looping through arr2
                                                                                break
                                                                        fi
                                                                        #if } after a not found look at the next arr2 entry
                                                                        count_arr2=($count_arr2+1)
                                                                done
								;;
							ahover_color)
                                                                #count our position in the array arr2
                                                                count_arr2=0
                                                                #for each entry in the arr2 array, do
                                                                for str3 in "${arr2[@]}"; do
                                                                        #check if the entry corresponds to the a:hover header
                                                                        if [[ $str3 == "a:hover"* ]]; then
                                                                                #jump down two lines (i.e. skip forward three entries in arr2)
                                                                                str4="${arr2[($count_arr2+2)]}"
                                                                                #update str4 (trim it) to just the color value
                                                                                str4=$(echo $str4 | awk -F ' ' '{print $2;}')
                                                                                #replace the color value found with the conf file value
                                                                                sed  -i "\|a:hover| {N;N;N;s|color: $str4|color: $var_value;|}" $str2
                                                                                #if this executes then stop looping through arr2
                                                                                break
                                                                        fi
                                                                        #if html,body not found look at the next arr2 entry
                                                                        count_arr2=($count_arr2+1)
                                                                done
								;;
							flagArea_image)
								#get the folder containing the flag(s)
								image_folder=$(echo $str2 | awk -F '/' '{for (i = 1; i <= (NF-2); i++) print $i}')
								image_folder=$(echo $image_folder/flags | sed -e "s| |/|g")
								#build the replacement filename and path from the custom conf
								image_file=$(echo $custom_folder/$var_value)
								timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
								echo "$timeinfo >> copying $image_file to /$image_folder/dhis2.png..."
								#verify the custom replacement file exists
								if [ -r $image_file ]; then
									#replace the dhis2.png file with the custom image
									cp $image_file /$image_folder/dhis2.png
								else
					                                #TODO Error handling here - the conf file filename was not found.
									echo timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
                                					echo "$timeinfo !! Error!"
                                					echo "$timeinfo > The conf file contains a filename that cannot be found/read.  The line reads:"
                                					echo $str1
                                					exit
								fi
								;;
							flagArea_border_color)
                                                                #count our position in the array arr2
                                                                count_arr2=0
                                                                #for each entry in the arr2 array, do
                                                                for str3 in "${arr2[@]}"; do
                                                                        #check if the entry is a open curly below an "#flagArea" header
                                                                        if [[ $str3 == "{"* && "${arr2[($count_arr2-1)]}" == "#flagArea"* ]]; then
                                                                                #jump down five lines (i.e. skip forward four entries in arr2)
                                                                                str4="${arr2[($count_arr2+4)]}"
                                                                                #update str4 (trim it) to just the color value
                                                                                str4=$(echo $str4 | awk -F ' ' '{print $4;}')
                                                                                #replace the border value found with the conf file value
                                                                                sed  -i "\|#flagArea| {N;N;N;N;N;s|border: 1px solid $str4|border: 1px solid $var_value;|}" $str2
                                                                                #if this executes then stop looping through arr2
                                                                                break
                                                                        fi
                                                                        #if } after a not found look at the next arr2 entry
                                                                        count_arr2=($count_arr2+1)
                                                                done
								;;
							flagArea_max_width)
                                                                #replace the max_width under #flagArea section
								sed  -i "\|#flagArea| {N;N;N;N;N;N;N;s|max-width: .*px;|max-width: $var_value;|}" $str2
								;;
							titleArea_top)
                                                                #count our position in the array arr2
                                                                count_arr2=0
                                                                #for each entry in the arr2 array, do
                                                                for str3 in "${arr2[@]}"; do
                                                                        #check if the entry is a open curly below an "#titleArea" header
                                                                        if [[ $str3 == "{"* && "${arr2[($count_arr2-1)]}" == "#titleArea"* ]]; then
                                                                                #jump down two lines (i.e. skip forward two entries in arr2)
                                                                                str4="${arr2[($count_arr2+2)]}"
                                                                                #update str4 (trim it) to just the color value
                                                                                str4=$(echo $str4 | awk -F ' ' '{print $2;}')
                                                                                #replace the top value found with the conf file value
                                                                                sed  -i "\|#titleArea| {N;N;N;s|top: $str4|top: $var_value;|}" $str2
                                                                                #if this executes then stop looping through arr2
                                                                                break
                                                                        fi
                                                                        #if } after a not found look at the next arr2 entry
                                                                        count_arr2=($count_arr2+1)
                                                                done
								;;
							titleArea_left)
                                                                #count our position in the array arr2
                                                                count_arr2=0
                                                                #for each entry in the arr2 array, do
                                                                for str3 in "${arr2[@]}"; do
                                                                        #check if the entry is a open curly below an "#titleArea" header
                                                                        if [[ $str3 == "{"* && "${arr2[($count_arr2-1)]}" == "#titleArea"* ]]; then
                                                                                #jump down three lines (i.e. skip forward three entries in arr2)
                                                                                str4="${arr2[($count_arr2+3)]}"
                                                                                #update str4 (trim it) to just the color value
                                                                                str4=$(echo $str4 | awk -F ' ' '{print $2;}')
                                                                                #replace the left value found with the conf file value
                                                                                sed  -i "\|#titleArea| {N;N;N;N;s|left: $str4|left: $var_value;|}" $str2
                                                                                #if this executes then stop looping through arr2
                                                                                break
                                                                        fi
                                                                        #if } after a not found look at the next arr2 entry
                                                                        count_arr2=($count_arr2+1)
                                                                done
								;;
							introArea_width)
                                                                #count our position in the array arr2
                                                                count_arr2=0
                                                                #for each entry in the arr2 array, do
                                                                for str3 in "${arr2[@]}"; do
                                                                        #check if the entry is a open curly below an "#introArea" header
                                                                        if [[ $str3 == "{"* && "${arr2[($count_arr2-1)]}" == "#introArea"* ]]; then
                                                                                #jump down one line (i.e. skip forward one entry in arr2)
                                                                                str4="${arr2[($count_arr2+1)]}"
                                                                                #update str4 (trim it) to just the color value
                                                                                str4=$(echo $str4 | awk -F ' ' '{print $2;}')
                                                                                #replace the width value found with the conf file value
                                                                                sed  -i "\|#introArea| {N;N;s|width: $str4|width: $var_value;|}" $str2
                                                                                #if this executes then stop looping through arr2
                                                                                break
                                                                        fi
                                                                        #if } after a not found look at the next arr2 entry
                                                                        count_arr2=($count_arr2+1)
                                                                done
								;;
							introArea_top)
                                                                #count our position in the array arr2
                                                                count_arr2=0
                                                                #for each entry in the arr2 array, do
                                                                for str3 in "${arr2[@]}"; do
                                                                        #check if the entry is a open curly below an "#introArea" header
                                                                        if [[ $str3 == "{"* && "${arr2[($count_arr2-1)]}" == "#introArea"* ]]; then
                                                                                #jump down two lines (i.e. skip forward three entries in arr2)
                                                                                str4="${arr2[($count_arr2+3)]}"
                                                                                #update str4 (trim it) to just the color value
                                                                                str4=$(echo $str4 | awk -F ' ' '{print $2;}')
                                                                                #replace the top value found with the conf file value
                                                                                sed  -i "\|#introArea| {N;N;N;N;s|top: $str4|top: $var_value;|}" $str2
                                                                                #if this executes then stop looping through arr2
                                                                                break
                                                                        fi
                                                                        #if } after a not found look at the next arr2 entry
                                                                        count_arr2=($count_arr2+1)
                                                                done
								;;
							introArea_left)
                                                                #count our position in the array arr2
                                                                count_arr2=0
                                                                #for each entry in the arr2 array, do
                                                                for str3 in "${arr2[@]}"; do
                                                                        #check if the entry is a open curly below an "#introArea" header
                                                                        if [[ $str3 == "{"* && "${arr2[($count_arr2-1)]}" == "#introArea"* ]]; then
                                                                                #jump down three lines (i.e. skip forward three entries in arr2)
                                                                                str4="${arr2[($count_arr2+4)]}"
                                                                                #update str4 (trim it) to just the color value
                                                                                str4=$(echo $str4 | awk -F ' ' '{print $2;}')
                                                                                #replace the left value found with the conf file value
                                                                                sed  -i "\|#introArea| {N;N;N;N;N;s|left: $str4|left: $var_value;|}" $str2
                                                                                #if this executes then stop looping through arr2
                                                                                break
                                                                        fi
                                                                        #if } after a not found look at the next arr2 entry
                                                                        count_arr2=($count_arr2+1)
                                                                done
								;;
							introArea_color)
                                                                #count our position in the array arr2
                                                                count_arr2=0
                                                                #for each entry in the arr2 array, do
                                                                for str3 in "${arr2[@]}"; do
                                                                        #check if the entry is a open curly below an "#introArea" header
                                                                        if [[ $str3 == "{"* && "${arr2[($count_arr2-1)]}" == "#introArea"* ]]; then
                                                                                #jump down six lines (i.e. skip forward six entries in arr2)
                                                                                str4="${arr2[($count_arr2+5)]}"
                                                                                #update str4 (trim it) to just the color value
                                                                                str4=$(echo $str4 | awk -F ' ' '{print $4;}')
                                                                                #replace the color value found with the conf file value
                                                                                sed  -i "\|#introArea| {N;N;N;N;N;N;s|color: $str4|color: $var_value;|}" $str2
                                                                                #if this executes then stop looping through arr2
                                                                                break
                                                                        fi
                                                                        #if } after a not found look at the next arr2 entry
                                                                        count_arr2=($count_arr2+1)
                                                                done
								;;
                                                        logo_front)
                                                                #get the folder containing the front logo(s)
                                                                image_folder=$(echo $str2 | awk -F '/' '{for (i = 1; i <= (NF-2); i++) print $i}')
                                                                image_folder=$(echo $image_folder/security | sed -e "s| |/|g")
                                                                #build the replacement filename and path from the custom conf
                                                                image_file=$(echo $custom_folder/$var_value)
                                                                echo "copying $image_file to /$image_folder/logo_front.png..."
                                                                #verify the custom replacement file exists
                                                                if [ -r $image_file ]; then
                                                                        #replace the logo_front.png file with the custom image
                                                                        cp $image_file /$image_folder/logo_front.png
                                                                else
                                                                        #TODO Error handling here - the conf file filename was not found.
                                                                        timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
									echo "$timeinfo !! Error!"
                                                                        echo "$timeinfo > The conf file contains a filename that cannot be found/read.  The line reads:"
                                                                        echo $str1
                                                                        exit
                                                                fi
                                                                ;;
                                                        logo_banner)
                                                                #get the folder containing the flag(s)
                                                                image_folder=$(echo $str2 | awk -F '/' '{for (i = 1; i <= (NF-3); i++) print $i}')
                                                                image_folder=$(echo $image_folder/images | sed -e "s| |/|g")
                                                                #build the replacement filename and path from the custom conf
                                                                image_file=$(echo $custom_folder/$var_value)
                                                                echo "copying $image_file to /$image_folder/logo_banner.png..."
                                                                #verify the custom replacement file exists
                                                                if [ -r $image_file ]; then
                                                                        #replace the logo_banner.png file with the custom image
                                                                        cp $image_file /$image_folder/logo_banner.png
                                                                else
                                                                        #TODO Error handling here - the conf file filename was not found.
									timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
                                                                        echo "$timeinfo !! Error!"
                                                                        echo "$timeinfo > The conf file contains a filename that cannot be found/read.  The line reads:"
                                                                        echo $str1
                                                                        exit
                                                                fi
                                                                ;;
						esac
						var_flag_no=1
					fi
				done
				#echo $css_instance
	                        if [[ $var_flag_no == 0 ]]; then
                	                #TODO Error handling here - the conf file contained entries corresponding to that were not found in the system.
					timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
                        	        echo "$timeinfo !! Error!"
                                	echo "$timeinfo > The conf file contains entries that could not be applied/executed, as the corresponding"
	                                echo "            Tomcat / dhis2 system could not be found.  The line reads:"
        	                        echo $str1
                	                exit
                        	fi
			else
				#TODO Error handling here - the line returned a value not handled by any previous section.
				timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
				echo "$timeinfo !! Error!"
				echo "$timeinfo > The conf file contains entries that cannot be understood.  The line reads:"
				echo $str1
				exit
			fi
		done
	else
		#TODO Error handling here - the line returned a value not handled by any previous section.
		timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
		echo "$timeinfo !! Error!"
		echo "$timeinfo > The customise.conf file cannot be found!  Unable to proceed.  Looking for:"
		echo $custom_conf
		exit
	fi
} 2>&1 | tee $logfile
