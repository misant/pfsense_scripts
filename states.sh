#!/bin/sh
#Auto recover script VER 1.0
#Bekhterev Evgeniy 21.09.2016

##########################
#Set variables
gwName="WAN2"
voipNet="192.168.0.0/16"
##########################

 
reset_voip_states() {
   echo "Reset states"
   /sbin/pfctl -k $voipNet
}

gwStat=`/root/gw.php | grep $gwName | awk -F'[:]' '{print $5}'`

if [ "$gwStat" == "Online" ]
    then
        echo "$gwName is ONLINE!"
        test -f ~/off.lbl && reset_voip_states && rm ~/off.lbl || echo "No mark, everything is ok"
    else
        echo "$gwName is OFFLINE!"
        touch ~/off.lbl
fi
