#!/bin/sh

#Auto recover script VER 1.2
#Bekhterev Evgeniy 23.09.2016

##########################
# Set variables
# nicName - backup network interface, states will be killed on that nic after main Gateway was restored
nicName="vmx0"
# gwName - main Gateway name, its state is monitored
gwName="WAN2_DHCP"
# voipNet - network, for which stated will be killed. If network is 172.16.30.0/24, you need to set it as 172.16.30 (as it used in grep)
voipNet="192.168.1"
# workdir - directory where all related files will be stored 
workDir="/root/states"
##########################

CURDATE=`/bin/date "+%Y%m%d:%H%M"`

reset_id_states() {
    /bin/echo "$CURDATE:Resetting states"
    /sbin/pfctl -i $nicName -ss -vv | /usr/bin/grep -A 2 $voipNet > $workDir/states.list

    /usr/bin/grep id $workDir/states.list | while read -r line; do
        stateID=`/bin/echo $line | /usr/bin/awk -F'[ ]' '{print $2}'`
        /bin/echo "$CURDATE:pfctl -i $nicName -k id -k $stateID"
        /sbin/pfctl -i $nicName -k id -k $stateID

    done
#   /bin/rm $workDir/states.list
}

 reset_source_states() {
      /bin/echo "$CURDATE:Resetting states"
     # Get states
      /sbin/pfctl -i $nicName -ss -vv | /usr/bin/grep $voipNet > $workDir/states.list
  
      /bin/cat $workDir/states.list | while read -r line; do
         # get source of state 
          src=`/bin/echo $line | /usr/bin/awk -F'[ ]' '{print $3}' | /usr/bin/awk -F'[:]' '{print $1}'`
         # get destination of state
          dst=`/bin/echo $line | /usr/bin/awk -F'[ ]' '{print $6}' | /usr/bin/awk -F'[:]' '{print $1}'`
          /bin/echo "$CURDATE:pfctl -i $nicName -k $src -k $dst"
         # kill state from $src to $dst on $nicName
          /sbin/pfctl -i $nicName -k $src -k $dst
      done
     # remove states list
#      /bin/rm $workDir/states.list
  }

gwStat=`$workDir/gw.php | /usr/bin/grep $gwName | /usr/bin/awk -F'[:]' '{print $5}'`

if [ "$gwStat" == "Online" ]
    then
        /bin/echo "$CURDATE:$gwName is ONLINE!"
        /bin/test -f $workDir/off.lbl && reset_source_states && /bin/rm $workDir/off.lbl || /bin/echo "$CURDATE:No mark, everything is ok"
    else
        /bin/echo "$CURDATE:$gwName is OFFLINE!"
        /usr/bin/touch $workDir/off.lbl
fi
