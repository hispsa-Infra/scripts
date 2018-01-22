#!/bin/bash
#_   _ _____ ___________   _____  ___
#| | | |_   _/  ___| ___ \ /  ___|/ _ \
#| |_| | | | \ `--.| |_/ / \ `--./ /_\ \
#|  _  | | |  `--. \  __/   `--. \  _  |
#| | | |_| |_/\__/ / |     /\__/ / | | |
#\_| |_/\___/\____/\_|     \____/\_| |_/
#Update the bashrc with the HISP standard
#Author	: Renier Rousseau
#Created Date : Jan 2018

#This file needs to be run as root.
echo "This file needs to be run as root."

#Make Workspace
mkdir /tmp/.working.bashrcMod
wget -P /tmp/.working.bashrcMod https://raw.githubusercontent.com/hispsa-Infra/scripts/master/quickFix/bashrc.conf

#Updating Skel
# - backup
cp /etc/skel/.bashrc /tmp/.working.bashrcMod
# - overwrite
cp /tmp/.working.bashrcMod/bashrc.conf /etc/skel/.bashrc

#Moving though users and updating thier bashrc
users_ls=($(ls /home/))
for user in "${users_ls[@]}"; do
  echo "$user - Updating bashrc"
  cp /etc/skel/.bashrc /home/$user/.bashrc
  chown $user:$user /home/$user/.bashrc
done

#Clean Workspace
rm -R /tmp/.working.bashrcMod
