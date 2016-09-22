#!/bin/sh

#Auto recover script VER 1.1
#Bekhterev Evgeniy 22.09.2016

##########################
# Set variables
# nicName - backup network interface, states will be killed on that nic after main Gateway was restored
nicName="bge0"
# gwName - main Gateway name, its state is monitored
gwName="Beeline"
# voipNet - network, for which states will be killed. If network is 172.16.30.0/24, you need to set it as 172.16.30 (as it used in grep)
voipNet="192.168.185.254"
##########################

CURDATE=`date "+%Y%m%d:%H%M"`

# Function for resetting states. 
# Enlists all state on $nicName interface for $voipNet and saves in states.list
reset_voip_states() {
    echo "$CURDATE:Resetting states"
    # Get states
    /sbin/pfctl -i $nicName -ss -vv | grep $voipNet > states.list

    /bin/cat /root/states/states.list | while read -r line; do
        # get source of state 
        src=`echo $line | awk -F'[ ]' '{print $3}' | awk -F'[:]' '{print $1}'`
        # get destination of state
        dst=`echo $line | awk -F'[ ]' '{print $6}' | awk -F'[:]' '{print $1}'`
        echo "$CURDATE:pfctl -i $nicName -k $src -k $dst"
        # kill state from $src to $dst on $nicName
        /sbin/pfctl -i $nicName -k $src -k $dst
    done
    # remove states list
    rm states.list
}

# check gwName state
gwStat=`/root/states/gw.php | grep $gwName | awk -F'[:]' '{print $5}'`

if [ "$gwStat" == "Online" ]
    then
        echo "$CURDATE:$gwName is ONLINE!"
        # if gwName is online, we need check if it was offline or not, if was - start reset_voip_states function and remove label
        test -f ~/states/off.lbl && reset_voip_states && rm ~/states/off.lbl || echo "$CURDATE:No mark, everything is ok"
    else
        echo "$CURDATE:$gwName is OFFLINE!"
        # create label that gwName was offline
        touch ~/states/off.lbl
fi
