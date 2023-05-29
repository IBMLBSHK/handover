#!/bin/sh

### to get information from VIOS

SYSSERVER=$1
VIOSID=$2

echo $SYSSERVER $VIOSID

VIOSCMD="viosvrcmd -m $SYSSERVER --id $VIOSID -c "

echo "$VIOSCMD"

echo "Execution date:"
date

echo "VIOS hostname:"
$VIOSCMD "hostname"

$VIOSCMD "lsdev -vpd"

##echo "FC info: "
##lscfg | grep -i fcs | awk {'print $2'} | xargs -i fcstat {} | egrep "REPORT|link|ID|Type:|Speed|Name:"

echo "NPIV map info: "
$VIOSCMD "lsmap -all -npiv -fmt : -field 'name' 'Physloc' 'ClntID' 'ClntName' 'FC name' 'FC loc code' 'VFC client name' 'VFC client DRC' 'Status'"

echo "vSCSI map info: "
$VIOSCMD "/usr/ios/cli/ioscli lsmap -all -fmt :"


