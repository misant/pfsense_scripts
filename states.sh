#!/bin/sh

#Auto recover script VER 1.1
#Bekhterev Evgeniy 22.09.2016

##########################
# Set variables
# nicName - backup network interface, states will be killed on that nic after main Gateway was restored
nicName="bge0"
# gwName - main Gateway name, its state is monitored
gwName="Beeline"
# voipNet - network, for which stated will be killed. If network is 172.16.30.0/24, you need to set it as 172.16.30 (as it used in grep)
voipNet="192.168.185.254"
##########################

CURDATE=`/bin/date "+%Y%m%d:%H%M"`

reset_voip_states() {
    /bin/echo "$CURDATE:Resetting states"
    /sbin/pfctl -i $nicName -ss -vv | /usr/bin/grep -A 3 $voipNet > states.list

    /usr/bin/grep id /root/states/states.list | while read -r line; do
        stateID=`/bin/echo $line | /usr/bin/awk -F'[ ]' '{print $2}'`
        /bin/echo "$CURDATE:pfctl -i $nicName -k id -k $stateID"
        /sbin/pfctl -i $nicName -k id -k $stateID

    done
    /bin/rm states.list
}

gwStat=`/root/states/gw.php | /usr/bin/grep $gwName | /usr/bin/awk -F'[:]' '{print $5}'`

if [ "$gwStat" == "Online" ]
    then
        /bin/echo "$CURDATE:$gwName is ONLINE!"
        /bin/test -f ~/states/off.lbl && reset_voip_states && /bin/rm ~/states/off.lbl || /bin/echo "$CURDATE:No mark, everything is ok"
    else
        /bin/echo "$CURDATE:$gwName is OFFLINE!"
        /usr/bin/touch ~/states/off.lbl
fi
