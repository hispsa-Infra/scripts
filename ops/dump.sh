#!/bin/bash
#_   _ _____ ___________   _____  ___
#| | | |_   _/  ___| ___ \ /  ___|/ _ \
#| |_| | | | \ `--.| |_/ / \ `--./ /_\ \
#|  _  | | |  `--. \  __/   `--. \  _  |
#| | | |_| |_/\__/ / |     /\__/ / | | |
#\_| |_/\___/\____/\_|     \____/\_| |_/
#Make a dump of a single database.
#Author	: Renier Rousseau
#Created Date 	: April 2018

#TODO test if the users as psql access i.e. is the postgres uesr.
#TODO either check for more than one argument or add multiple dumps for one command.
#TODO Standardise time stamps.


#Place where the backups will be stored localy
backup_dir="/tmp"

#start of backup info
dateinfo=`date '+%Y-%m-%d'`

#Get all datbases not owned by postgres
databases=`psql --tuples-only -P format=unaligned -c "SELECT datname FROM pg_database WHERE NOT datistemplate AND datname <> 'postgres'";`

#Error check to ensure that the command has an argument.
if [ $# -ne 1 ] ; then
  #if there are not Parameters
  echo "Please ensure to Use one of the following database as a argument for the command"
  echo "i.e. bash.sh <one of the following databases>"
  #Move though all the database listing them all
  for d in $databases; do
    #Printing out all the databases on the system.
    echo $d
  done
  #Check for the keyword all
elif [[ $1 = 'all' ]]; then
  #make the new backup dir.
  all_backup_dir="$backup_dir/$HOSTNAME-$dateinfo-dump"
  touch $all_backup_dir
  timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
  echo "$timeinfo > ** Starting Dump of databases **"
  #Move though all the database dumping them all
  for d in $databases; do
    #backuping up all the databases on the system.
    echo "database $d - making dump too $all_backup_dir/$d"
    #Do dump.
    /usr/bin/pg_dump --jobs=5 --exclude-table=analytics* --format=directory --file=$backup_dir/$d $d
  done
  #compressing the file
  timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
  echo "$timeinfo > ** Dump Completed - Compressing File **"
  7z a -mx=1 $all_backup_dir.7z $all_backup_dir

  #copy the dump to the dump server.
  timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
  echo "$timeinfo > ** Compressing Completed - Moveing File **"
  scp -P 722 $all_backup_dir.7z dump@10.0.1.245

  #closeing out
  timeinfo=`date '+%Y-%m-%d %H:%M:%S'`
  echo "$timeinfo > ** Dump Completed - File can be found at $all_backup_dir.7z and the dump server **"

else
  #Move though all the databases to ensure that the one requested exsists.
  #flag for error if db does exist
  flag_db_exsists=0

  #backup folder
  backup_dir="$backup_dir/$1-$dateinfo-dump"
  for d in $databases; do

    if [[ $1 = $d ]]; then
      #DB found update flag_db_exsists
      flag_db_exsists=1

      #echo the good news
      echo "database found! - making dump too $backup_dir"
      #Do dump.
      /usr/bin/pg_dump --jobs=5 --exclude-table=analytics* --format=directory --file=$backup_dir $1

      #compressing the file
      echo "dump completed - compressing file"
      7z a -mx=1 $backup_dir.7z $backup_dir

      #closeing out
      echo "dump of $1 completed - can be found at $backup_dir.7z"
    fi
  done
  #error if flag_db_exsists is 0
  if [[ $flag_db_exsists = 0 ]]; then
    #Error Message
    echo "$1 database was not found."
    echo "Please ensure to Use one of the following database as a argument for the command"
    echo "i.e. bash.sh <one of the following databases>"
    #Move though all the database listing them all
    for d in $databases; do
      #Printing out all the databases on the system.
      echo $d
    done
  fi
fi
