#!/bin/bash
#_   _ _____ ___________   _____  ___
#| | | |_   _/  ___| ___ \ /  ___|/ _ \
#| |_| | | | \ `--.| |_/ / \ `--./ /_\ \
#|  _  | | |  `--. \  __/   `--. \  _  |
#| | | |_| |_/\__/ / |     /\__/ / | | |
#\_| |_/\___/\____/\_|     \____/\_| |_/
#Will Start all tomcat instances it finds.
#Author	: Renier Rousseau
#Created Date 	: June 2018

#TODO add error checking on tocat folder.
#TODO add switch to print output of the log file.

#Varriables
tomcat_home="/tomcat"

#Get a list of all the Tomcat folders
tomcat_ls=($(ls $tomcat_home | grep tomcat))

#move though the list of tomcat folders
for tomcat_dir in "${tomcat_ls[@]}" ; do
  #find the user who owns that tomcat folders
  tomcat_usr=$(ls -l $tomcat_home | grep $tomcat_dir | cut -d " " -f 4)

  #startup the tomcat instance
  sudo su $tomcat_usr -c "bash $tomcat_home/$tomcat_dir/bin/startup.sh"

  if [[ ${#tomcat_ls[@]} > 1 ]]; then
    #sleep if there are more than 1 tomcat instances.
    sleep 40
  fi
done
