#!/bin/bash

# @author: ajfernandez
# @last_edit: 24/10/18
# @backupScript for classroom virtual machines

time=`date "+%d/%m/%Y %H:%M:%S"` # TODO: Get same time at every log entry,
# move `date..` into each log lines bellow [OK]

# usernames here
users=(
  "p2cfs1801"
  "p2cfs1812" # TODO: usernames, ip's and pass in csv file better?
  "p2cfs1810" # TODO: Implement hash of password using MD5 (md5sum) or SHA-2
)
userCount=${#users[@]}
# end usernames

# sources
sources=(
  "192.168.2.1"
  "192.168.2.10"
  "192.168.2.179"
)
# end sources

log="/var/log/backupLog"
# TODO: is it possible integration with Syslog or journalctl? research about module "imjournal" []
echo "LOG at `date "+%d/%m/%Y %H:%M:%S"`-----------------------------" >> $log

for (( i=0; i < userCount; i++ )); do
  printf "\nWorking on backup for ${users[i]}" >> $log
  if [[ ! -d  /mnt/"${users[i]}" ]]; then
    mkdir /mnt/"${users[i]}"
    echo "Destination mount: /mnt/${users[i]} created succesfully" >> $log
  elif [[ ! -d  /var/backupClassroom/"${users[i]}" ]]; then
    mkdir /var/backupClassroom/"${users[i]}"
    echo "Destination directory: /var/backupClassroom/${users[i]} created succesfully" >> $log
  fi

mount -t cifs -o user=nobody,password=nobody,vers=2.0 //"${sources[i]}"/"${users[i]}" /mnt/"${users[i]}"/

if [ "$?" -eq 0 ]; then
  echo "Source directory: //${sources[i]}/${users[i]} mounted succesfully" >> $log
else
  echo "Source directory: //${sources[i]}/${users[i]} failed to mount" >> $log
fi

echo "Initializing rsync for: ${users[i]} ot `date "+%d/%m/%Y %H:%M:%S"`" >> $log
rsync -avh --progress /mnt/"${users[i]}" /var/backupClassroom/"${users[i]}"

if [ "$?" -eq 0 ]; then
  echo "Backup for: ${users[i]} SUCCESFULLY finished at `date "+%d/%m/%Y %H:%M:%S"` in /var/backupClassroom/${users[i]}" >> $log
  umount /mnt/"${users[i]}"
  echo "Umount /mnt/${users[i]} SUCCESFULLY" >> $log
else
  echo "Backup for: ${users[i]} Rsync ERROR at `date "+%d/%m/%Y %H:%M:%S"` for ${users[i]}'s backup" >> $log
fi

done

printf "\nLOG FINISHED at `date "+%d/%m/%Y %H:%M:%S"`--------------------\n" >> $log



# rsync -avh --progress /mnt/ajfernandez /home/ajfernandez/backupVM @@@ --delete, so dangerous!
# mount -t cifs -o username=TYPEUSERNAME //192.168.2.1/ajfernandezVM /mnt/ajfernandez/
# smbclient --list 192.168.2.1 --user=TYPEUSERNAME
# smbclient -L 192.168.2.10 -U nobody -d 256 --> to check if the error is due to smb version
# df -h show mounted filesystem free space
# $? reuturn exit code of previous command: if [ "$?" -eq "0" ] then echo "done" else echo "error"
# ${arr[*]}         All of the items in the array
# ${!arr[*]}        All of the indexes in the array
# ${#arr[*]}        Number of items in the array
# ${#arr[0]}        Length of item zero
# @ -> Do the same that '*' but when we acces to this spare each item as separated word
