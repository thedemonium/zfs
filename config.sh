#!/usr/bin/env bash

lxd_storage='z5z2/containers'
backup_storage='z5z2/backups/containers'
remote_backup_storage='z5z2/backups/containers'
systempool='syspool/ROOT/ubuntu'
remote_backup_syspool='z5z2/backups/syspool'
hostname=`hostname`

containers='u14-gitlab u14-vertica-prod-node1 u14-web-internal u16-gdp-local u16-gdp-local-clone u18-asterisk u18-discourse u18-dns-slave u18-proxy-office u18-remba-win7 u18-samba-devel u18-trinity u18-unifi u18-wiki u18-win7'
snapshots=''

