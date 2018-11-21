#!/bin/bash

# читаем настройки
source /z5z2/scripts/zpool/config.sh

for container in $containers
do
  todelete=`lxc info $container | grep daily_ | sort  | awk '{print $1}' | head -n -10`
  zfsdelete=`zfs list -t snap | grep $lxd_storage"/"$container | sort  | awk '{print $1}' | head -n -10`

  if [ ! -z "$zfsdelete" ]; then
    delsnap=(${zfsdelete// / })
    for snap in ${delsnap[@]}
      do
        zfs release lockholder $snap
      done
  fi

  if [ ! -z "$todelete" ]; then
    delsnap=(${todelete// / })
    for snap in ${delsnap[@]}
      do
        lxc delete $container"/"$snap
      done
  fi
done
