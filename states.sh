#!/bin/sh
#Auto recover script VER 1.0
#Bekhterev Evgeniy 21.09.2016

##########################
#Set variables
gwName="WAN2"
voipNet="192.168.0.0/16"
##########################

CURDATE=`date "+%Y%m%d:%H%M"`
 
 
reset_voip_states() {
   echo "$CURDATE:Reset states"
   /sbin/pfctl -k $voipNet >> /root/states.log
}

gwStat=`/root/gw.php | grep $gwName | awk -F'[:]' '{print $5}'`

if [ "$gwStat" == "Online" ]
    then
        echo "$CURDATE:$gwName is ONLINE!"
        test -f ~/off.lbl && reset_voip_states && rm ~/off.lbl || echo "$CURDATE:No mark, everything is ok"
    else
        echo "$CURDATE:$gwName is OFFLINE!"
        touch ~/off.lbl
fi
