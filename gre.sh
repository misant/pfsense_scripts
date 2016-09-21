#!/bin/sh
 
#Auto reconnect script VER 1.0
 
#Status IPsec. 1 = Running.
IpsecStat=`/usr/local/sbin/ipsec status | grep "Ass" | awk -F'[(]' '{print $2}' | awk -F'[ ]' '{print $1}'`
#Local GRE IP
#GreLocal=`/sbin/ifconfig gre0 | grep "inet 172" | awk '{print ($2)}'`
#Remote GRE IP
GreRemote=`/sbin/ifconfig gre0 | grep "inet 172" | awk '{print ($4)}'`
CURDATE=`date "+%Y%m%d:%H%M"`
 
if [ "$IpsecStat" == "1" ]
    then
            TunStat=`/sbin/ping -c 5 $GreRemote | grep packets | awk '{print ($4)}'`
                    if [ "$TunStat" == "0" ]
                                then
                                     /sbin/pfctl -F states
                                     echo "$CURDATE:$RoundTrip:tunnel DOWN, resetting states">> /root/gre/gre.log
                                fi
fi
