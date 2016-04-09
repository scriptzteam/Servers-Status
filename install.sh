#!/bin/bash
# sCRiPTz-TEAM

cd
wget https://raw.githubusercontent.com/scriptzteam/Servers-Status/master/serverstatus.sh
chmod +x serverstatus.sh
#backup cron, just in case :D
cp /var/spool/cron/crontabs/root /root/root.crontab.backup
touch /var/www/html/server.json
chmod 644 /var/www/html/server.json
#add cron
croncmd="sh serverstatus.sh | sed ':a;N;$!ba;s/\n//g'> /var/www/html/server.json"
cronjob="*/1 * * * * $croncmd"
( crontab -l | grep -v "$croncmd" ; echo "$cronjob" ) | crontab -
