#!/bin/bash

find /var/lib/lxd/_sqlite_backup/* -type f -ctime +10 | xargs rm -rf