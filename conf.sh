#!/bin/sh
#Auto config script VER 1.2
#pfSense 2.2.4
#Bekhterv Evgeniy 10.08.2015
#
#Change Log:
#V1.0 Configure Network
#V1.1 IPsec peers and hostname added
#V1.2 Logs resetting added
#
#
#Read IPs from /conf/config.xml as it was in Backup file:
#LAN IP:
oldlan=`cat /conf/config.xml | grep -A 5 "<if>xl0</if>" | grep "ipaddr" | awk -F'[>]' '{print $2}' | awk -F'[<]' '{print $1}'`
#WAN IP:
oldwan=`cat /conf/config.xml | grep -A 5 "<if>xl0_vlan99</if>" | grep "ipaddr" | awk -F'[>]' '{print $2}' | awk -F'[<]' '{print $1}'`
#Calc WAN NET:
oldwnet=`echo $oldwan | cut -d. -f1-3`
#Mikrotik IP:
olddns=`cat /conf/config.xml | grep -A 5 "<dnsserver>" | grep $oldwnet | awk -F'[>]' '{print $2}' | awk -F'[<]' '{print $1}'`
#Calc LAN NET:
oldnet=`echo $oldlan | cut -d. -f1-3`
#Get HOSTNAME:
oldname=`cat /conf/config.xml | grep -m 1 "<hostname" | awk -F'[>]' '{print $2}' | awk -F'[<]' '{print $1}'`
#Get Local IPsec Peer:
oldpeer=`cat /conf/config.xml | grep "<myid_data" | awk -F'[>]' '{print $2}' | awk -F'[<]' '{print $1}'`

#Print values:
echo "config.xml LAN IP="$oldlan
echo "config.xml WAN IP="$oldwan
echo "Mikrotik VLAN99 IP="$olddns
echo "config.xml LAN NET="$oldnet".0/24"
echo "config.xml WAN NET="$oldwnet".0/24"
echo "config.xml Hostname="$oldname
echo "config.xml Local IPsec Peer IP="$oldpeer
echo "-------------------------------"

#New IPs as configured now:
#newlan=`ifconfig xl0 | grep "inet " | awk '{print ($2)}'`
#newwan=`ifconfig xl0_vlan99 | grep "inet " | awk '{print ($2)}'`

#Read IPs from input:
echo "INPUT LAN IP:"
read newlan
echo "INPUT WAN IP:"
read newwan
echo "INPUT HOSTNAME:"
read newname
echo "INPUT IPsec Local Peer IP:"
read newpeer

#Calc WAN NET:
wnet=`echo $newwan | cut -d. -f1-3`
#Calc WAN IP last octet:
wip=`echo $newwan | cut -d. -f4`
#Calc Mikrotik VLAN99 IP last octet:
gwip=$(($wip-1))
#Calc Mikrotik VLAN99 full IP:
newdns=`echo $wnet.$gwip`
#Calc LAN NET:
newnet=`echo $newlan | cut -d. -f1-3`


echo "-------------------------------"
echo "SET LAN IP="$newlan
echo "SET WAN IP="$newwan
echo "SET Mikrotik VLAN99 IP="$newdns
echo "SET LAN NET="$newnet".0/24"
echo "SET Hostname="$newname
echo "SET IPsec Local Peer IP="$newpeer


#Replace LAN IP in config.xml:
sed "s*$oldlan*$newlan*g" /conf/config.xml > /root/config.xml
#Replace WAN IP in config.xml:
sed "s*$oldwan*$newwan*g" /root/config.xml > /root/config2.xml
#Replace Mikrotik VLAN99 IP in config.xml:
sed "s*$olddns*$newdns*g" /root/config2.xml > /root/config.xml
#Replace LAN NET for IPsec in config.xml:
sed "s*$oldnet.0*$newnet.0*g" /root/config.xml > /root/config2.xml
#Replace HOSTNAME in config/xml:
sed "s*$oldname*$newname*g" /root/config2.xml > /root/config.xml
#Replace IPsec Local Peer:
sed "s*$oldpeer*$newpeer*g" /root/config.xml > /root/config2.xml


#Replace old config.xml with new one:
mv /conf/config.xml /conf/config.xml.old
mv /root/config2.xml /conf/config.xml
rm /root/config.xml

#Replace IPs and NETs in ipcad.conf:
sed "s*$oldnet.0*$newnet.0*g" /usr/local/etc/ipcad.conf > /root/ipcad.conf
sed "s*$olddns*$newdns*g" /root/ipcad.conf > /root/ipcad2.conf
sed "s*$oldnet.254*$newnet.254*g" /root/ipcad2.conf > /root/ipcad.conf
sed "s*$oldnet.255*$newnet.255*g" /root/ipcad.conf > /root/ipcad2.conf
#Replace ipcad.conf
mv /usr/local/etc/ipcad.conf /usr/local/etc/ipcad.conf.old
mv /root/ipcad2.conf /usr/local/etc/ipcad.conf
rm /root/ipcad.conf

#Replace values in lightsqid skipuser.cfg:
sed "s*$oldnet.254*$newnet.254*g" /usr/local/etc/lightsquid/skipuser.cfg > /root/skipuser.cfg
sed "s*$oldnet.255*$newnet.255*g" /root/skipuser.cfg > /root/skipuser2.cfg
#Replace file with new one:
mv /usr/local/etc/lightsquid/skipuser.cfg /usr/local/etc/lightsquid/skipuser.cfg.old
mv /root/skipuser2.cfg /usr/local/etc/lightsquid/skipuser.cfg
rm /root/skipuser.cfg

#Replace NET in tolog.sh script:
sed "s*$oldnet*$newnet*g" /usr/local/sbin/tolog.sh > /root/tolog2.sh
#Replace script:
mv /usr/local/sbin/tolog.sh /usr/local/sbin/tolog.sh.old
mv /root/tolog2.sh /usr/local/sbin/tolog.sh
echo "-------------------------------"
#Remove logs restored from backup
echo "Auto configuration done."
echo "-------------------------------"
echo "Reset Squid logs and reports? (y/n)"
read logr
    if [ "$logr" == "y" ]
	then
#	    log_files="system filter dhcpd vpn pptps poes l2tps openvpn portalauth ipsec ppp relayd wireless lighttpd ntpd gateways resolver routing installer"
#	    for word in $log_files
#		do
#		     echo "Resetting "$word".log"
#		     unlink /var/log/$word.log
#		     touch /var/log/$word.log
#	    done
#	/usr/bin/killall syslogd
#	echo "------------------------------------"
#	echo "Log files will start after rebooting"
	echo "Deleting Lightsquid reports.."
	rm -r /var/lightsquid/report/*
	echo "Deleting Squid logs.."
	rm /var/squid/logs/access.log
#	echo "Resetting RRD data.."
#	rm /var/db/rrd/*
	echo "---------------Done-----------------"
	else
	    echo "As you wish! :)"
    fi

rm /conf/trigger_initial_wizard    
echo "Do you want to reboot? (y/n)"
read ans
    if [ "$ans" == "y" ]
	then
		echo "Rebooting.."
		/sbin/reboot
	else
		echo "Exiting script session.."
    fi

	

