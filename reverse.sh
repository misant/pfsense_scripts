#!/bin/sh

PingResult=`/sbin/ping -c 10 172.16.72.254 | /usr/bin/grep loss | /usr/bin/awk '{print $4}'`
CurDate=`/bin/date`
if [ $PingResult -le 9 ]
   then       
       /bin/echo "$CurDate | Need to replace IP!" >> /root/check.txt
       /usr/bin/sed "s*172.16.72.250*172.16.72.254*g" /conf/config.xml > /root/config.xml
       /bin/mv /root/config.xml /conf/config.xml
       /bin/rm /tmp/config.cache
       /etc/rc.reload_all
   else
       /bin/echo "$CurDate | Its ok" >> /root/check.txt
fi
