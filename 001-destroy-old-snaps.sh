#!/bin/bash

# читаем настройки
source /z5z2/scripts/zpool/config.sh

for snapshot in $snapshots
do
  todelete=`zfs list -t snap | grep $backup_storage"/"$snapshot | sort  | awk '{print $1}' | head -n -10`
  if [ ! -z "$todelete" ]; then
    delsnap=(${todelete// / })
    for snap in ${delsnap[@]}
      do
        zfs release lockholder $snap
        zfs destroy $snap
      done
  fi
done
