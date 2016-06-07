#!/bin/sh
clients=`arp -a | grep -v 10.254.0.1 | grep 10.254.0. | awk '{print ($2)}' | tr -d \)\(`
#echo $clients
for i in $clients
 do
 if ping -c 1 -t 1 $i | grep "0 packets received";
 then
 arp -d $i
# echo "not ok"
 else
# echo "ok"
 fi
 done
