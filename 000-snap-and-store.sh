#!/bin/bash

# берём текущее время
date=`date +%Y-%m-%d`

## Для работы скрипта нужно сделать ##
#
# 1) Создать пул для бекапа
# zfs create zpool/backups
# zfs create zpool/backups/containers
# 
# 2) Создать папку для бекапа базы и поставить sqlite3
# mkdir -p /var/lib/lxd/_sqlite_backup/
# apt install -y sqlite3
#
# 3) Добавить скрипт в crontab
# 10 22 * * * root /srv/scripts/000-snap-and-store.sh

# читаем настройки
source /z5z2/scripts/zpool/config.sh


# бекапим sqlite базу /var/lib/lxd/lxd.db
/usr/bin/sqlite3 /var/lib/lxd/lxd.db '.dump' |gzip >/var/lib/lxd/_sqlite_backup/$date.sql.gz

# бекапим контейнеры
for container in $containers
do
    # делаем снепшот контейнера
    /usr/bin/lxc snapshot $container "daily_"$date

    # ставим hold на снепшот, чтобы предотвратить случайное удаление контейнера
    /sbin/zfs hold lockholder $lxd_storage"/"$container"@snapshot-daily_"$date

    # получаем последний backup снепшот
    lastbackup=`ssh root@192.168.0.194 zfs list -t snap | grep daily_ | grep $remote_backup_storage"/"$container | sort | tail -n 1 | awk '{print $1}'` 
    #lastbackup=z5z2/backups/containers/u14-gitlab@snapshot-daily_2018-10-22
    #echo lastbackup: $lastbackup

    # получаем последний снепшот контейнера
    lastsnap=`zfs list -t snap | grep daily_ | grep $lxd_storage"/"$container | sort | tail -n 1 | awk '{print $1}'` 
    #lastsnap=z5z2/containers/u14-gitlab@snapshot-daily_2018-10-23
    #echo lastsnap: $lastsnap

    # подставляем дату последнего снепшота
    basebackup=`echo $lastbackup| sed 's:z5z2/backups/:z5z2/:g'`
    #basebackup=z5z2/containers/u14-gitlab@snapshot-daily_2018-10-22
    #echo basebackup: $basebackup

    # отправляем инкримент снепшот контейнера в пул бекапов
    zfs send -i $basebackup $lastsnap | ssh root@192.168.0.194 zfs recv -vF $backup_storage"/"$container
done
