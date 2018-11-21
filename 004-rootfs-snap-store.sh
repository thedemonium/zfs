#!/bin/bash

# берём текущее время
date=`date +%Y-%m-%d`

source /z5z2/scripts/zpool/config.sh

zfs snapshot $systempool"@"$hostname"_"$date


# получаем последний backup снепшот
lastsysbackup=`ssh root@192.168.0.194 zfs list -t snap | grep $remote_backup_syspool | sort | tail -n 1 | awk '{print $1}'`
echo lastsysbackup: $lastsysbackup

# получаем последний снепшот 
lastsyssnap=`zfs list -t snap  | grep $systempool | sort | tail -n 1 | awk '{print $1}'`
echo lastsyssnap: $lastsyssnap

# подставляем дату последнего снепшота
basesysbackup=`echo $lastsysbackup | sed 's:z5z2/backups/syspool:syspool/ROOT/ubuntu:g'`
#lastsysbackup: z5z2/backups/syspool@lxc-office3_2018-10-23
#lastsyssnap:    syspool/ROOT/ubuntu@lxc-office3_2018-10-24
echo basesysbackup: $basesysbackup
# syspool/ROOT/ubuntu@lxc-office3_2018-10-23

# отправляем инкримент снепшот контейнера в пул бекапов
zfs send -i $basesysbackup $lastsyssnap | ssh root@192.168.0.194 zfs recv -vF $remote_backup_syspool
