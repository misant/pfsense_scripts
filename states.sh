#!/bin/sh
 
#Auto recover script VER 1.0
 
reset_voip_states() {
   echo "Reset states"
   /sbin/pfctl -k 192.168.0.0/16
}

gwStat=`/root/gw.php | grep WAN2 | awk -F'[:]' '{print $5}'`

if [ "$gwStat" == "Online" ]
    then
        echo "WAN2 GW is ONLINE!"
        test -f ~/off.lbl && reset_voip_states && rm ~/off.lbl || echo "No mark, everything is ok"
    else
        echo "WAN2 GW is OFFLINE!"
        touch ~/off.lbl
fi
