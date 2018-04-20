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
#TODO add an all argument to do a full dump.


#Place where the backups will be stored localy
backup_dir="/tmp"

#start of backup info
dateinfo=`date '+%Y-%m-%d'`

#backup folder
backup_dir="$backup_dir/$1-$dateinfo-dump"

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
else
  #Move though all the databases to ensure that the one requested exsists.
  #flag for error if db does exist
  flag_db_exsists=0
  for d in $databases; do

    if [[ $1 = $d ]]; then
      #DB found update flag_db_exsists
      flag_db_exsists=1

      #echo the good news
      echo "database found! - making backup too $backup_dir"
      #Do dump.
      /usr/bin/pg_dump --jobs=5 --exclude-table=analytics* --format=directory --file=$backup_dir $1

      #inform user of dump being finished.
      echo "dump for $1 completed. You can find it at $backup_dir. other useful commands are :"
      echo "Zipping it :"
      echo "7z a -mx=1 $backup_dir.zip $backup_dir"
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
