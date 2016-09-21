#!/usr/local/bin/php -f
<?php
include_once "/etc/inc/globals.inc";
include_once "/etc/inc/config.inc";
include_once "/etc/inc/util.inc";
include_once "/etc/inc/pfsense-utils.inc";
include_once "/etc/inc/functions.inc";

//var_dump($argv);
$nocsrf = true;
//require_once("/usr/local/www/guiconfig.inc");
require_once("/etc/inc/pfsense-utils.inc");
require_once("/etc/inc/functions.inc");
$a_gateways = return_gateways_array();
$gateways_status = array();
$gateways_status = return_gateways_status(true);
$counter = 1;
foreach ($a_gateways as $gname => $gateway) {
echo $gateway['name'],":";
if (is_ipaddr($gateway['gateway']))
                                echo $gateway['gateway'],":";
                        else
                                echo get_interface_gateway($gateway['friendlyiface']),":";
if ($gateways_status[$gname])
                                echo $gateways_status[$gname]['delay'],":";
                        else
                                echo "Gathering data:";
if ($gateways_status[$gname])
                                echo $gateways_status[$gname]['loss'],":";
                        else
                                echo "Gathering data:";
if ($gateways_status[$gname]) {
                                if (stristr($gateways_status[$gname]['status'], "down")) {
                                        $online = "Offline";
                                } elseif (stristr($gateways_status[$gname]['status'], "loss")) {
                                        $online = "Warning, Packetloss";
                                } elseif (stristr($gateways_status[$gname]['status'], "delay")) {
                                        $online = "Warning, Latency";
                                } elseif ($gateways_status[$gname]['status'] == "none") {
                                        $online = "Online";
                                }
                        } else {
                                $online = "Gathering data";
                        }
echo "$online\n";

$counter++;
}
?>
