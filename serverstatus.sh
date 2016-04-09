#!/bin/bash
#*/1 * * * *  sh serverstatus.sh | sed ':a;N;$!ba;s/\n//g'> /home/server.json 
#sCRiPTz-TEAM.iNFO

# Network interface for the IP address
iface="venet0:0"
# network interface for traffic monitoring (RX/TX bytes)
iface2="eth0"

ipaddr="1.2.3.4"

#json start
echo -n "{"

echo -n "\"Services\": { "
SERVICE=apache2
if ps ax | grep -v grep | grep $SERVICE > /dev/null; then echo -n "\"$SERVICE\" : \"running\","; else echo -n "\"$SERVICE\" : \"not running\","; fi
SERVICE=sshd
if ps ax | grep -v grep | grep $SERVICE > /dev/null; then echo -n "\"$SERVICE\" : \"running\","; else echo -n "\"$SERVICE\" : \"not running\","; fi
SERVICE=syslog
if ps ax | grep -v grep | grep $SERVICE > /dev/null; then echo -n "\"$SERVICE\" : \"running\","; else echo -n "\"$SERVICE\" : \"not running\","; fi
SERVICE=mysql
if ps ax | grep -v grep | grep $SERVICE > /dev/null; then echo -n "\"$SERVICE\" : \"running\","; else echo -n "\"$SERVICE\" : \"not running\","; fi
#LAST SERVICE HAS TO BE WITHOUT , FOR VALID JSON!!!
SERVICE=python
if ps ax | grep -v grep | grep $SERVICE > /dev/null; then echo -n "\"$SERVICE\" : \"running\""; else echo -n "\"$SERVICE\" : \"not running\""; fi
echo -n " }, "

#disk
echo -n "\"Disk\" : { ";
echo -n "\""
#df -h -T -xtmpfs -xdevtmpfs -xrootfs | awk '{print "\"device\" : \""$1"\", \"type\" : \""$2"\", \"total\" : \"" $3"\", \"used\" : \""$4"\", \"free\" : \""$5"\", \"percentage\" : \""$6"\", \"mounted on\" : \""$7"\""'}
df -h --total | awk  ' /total/ { print "total\" : \""$2"\", \"used\" : \""$3"\", \"free\" : \""$4"\", \"percentage\" : \""$5" " }'
echo -n "\" }, "

# Load
echo -n "\"Load\" : \""
#if $(echo `uptime`  | sed 's/  / /g' | grep -E "min|days" >/dev/null); then echo `uptime` | sed s/,//g | awk '{ printf $10 }'; else echo `uptime` | sed s/,//g| awk '{ printf $8 }'; fi
uptime | grep -ohe 'load average[s:][: ].*' | awk '{ print $3 }'
echo -n "\", "

#Users:
echo -n "\"Users logged on\" : \""
#if $(echo `uptime` | sed 's/  / /g' | grep -E "min|days" >/dev/null); then echo `uptime` | sed s/,//g | awk '{ printf $6 }'; else echo `uptime` | sed s/,//g| awk '{ printf  $4 }'; fi
uptime | grep -ohe '[0-9.*] user[s,]' | awk '{ print $1 }'
echo -n "\", "

#Uptime 
echo -n "\"Uptime\" : \""
#if $(echo `uptime` | sed 's/  / /g' | sed 's/,//g' | grep -E "days" >/dev/null); then echo `uptime` | sed s/,//g | awk '{ printf $3" "$4 }'; else echo `uptime` | sed s/,//g| awk '{ printf  3 }'; fi
uptime | grep -ohe 'up .*' | sed 's/,//g' | awk '{ print $2" "$3 }'
echo -n "\", "


# Memory
echo -n "\"Free RAM\" : \""
free -m | grep -v shared | awk '/buffers/ {printf $4 }'
echo -n "\", "
echo -n "\"Total RAM\" : \""
free -m | grep -v shared | awk '/Mem/ {printf $2 }'
echo -n "\", "



# local ip
#ips=`hostname --ip-address`
ipsaddr=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
echo -n "\"IPv4\" : \""
#ip -f inet a | grep "$iface" | awk '/inet/{printf $2 }'
echo $ipsaddr
echo -n "\","

#hostname
echo -n "\"Hostname\" : "
echo -n "\"`hostname`\", "

# network traffic
rxbytes=`/sbin/ifconfig $iface2 | awk '{ gsub(/\:/," ") } ; { print  } ' | awk '/RX\ b/ { print $3 }'`
echo -n "\"rxbytes\" : \""
echo -n $rxbytes
echo -n "\", "

txbytes=`/sbin/ifconfig $iface2 | awk '{ gsub(/\:/," ") } ; { print  } ' | awk '/RX\ b/ { print $8 }'`
echo -n "\"txbytes\" : \""
echo -n $txbytes
echo -n "\", "


# package updates, uncomment for your distro
#echo -n "\"updatesavail\" : \""
#debian/ubuntu
#echo -n `apt-get -s upgrade | awk '/[0-9]+ upgraded,/ {print $1}'`
#arch
#echo -n `pacman -Sy 1>/dev/null 2>&1; pacman -Qu | wc -l`
#yum (centos/fedora/RHEL)
# echo -n `yum -q check-update | wc -l`
#echo -n "\","

#json close
echo -n "\"JSON\" : \"close\""
echo; echo -n " } "
