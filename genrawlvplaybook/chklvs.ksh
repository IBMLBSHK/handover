#!/bin/ksh

ParmA=$1
if [[ -z $ParmA ]]
then
   echo "ERR: chklvs.ksh requires 2 inputs 1st remote hostname and output path for genrawlvsyaml.ksh"
   echo "1st input is remote username"
   echo "Example: chklvs.ksh cdcsrv82 /tmp/chklvs_20220209.tmp"
   echo "Press enter to exit."
   read
   exit 91
fi


ParmB=$2

if [[ -z $ParmB ]]
then
   echo "ERR: chkvgfree.ksh requires inputs remote hostname"
   echo "Please input remote hostname"
   echo "Example: chklvs.ksh cdcsrv82 /tmp/chklvs_20220209.tmp"
   echo "Press enter to exit:"
   read
   exit 92
fi


#Get hostname last 2 char
HOST=$ParmA
AVFFILE=$ParmB

LENHOST=`echo ${#HOST}`
SLENHOST=`expr $LENHOST - 1`
#hostname last 2 char
VGNAMEP1=`expr substr $HOST $SLENHOST 2`
#echo "VGNAMEP1: $VGNAMEP1"
#-----------------------------------------
#HARD SET Variable for development
#-----------------------------------------
#VGNAMEP1=e9

cp /dev/null $AVFFILE
#For LV list
TMPLVLIST="/tmp/${HOST}_TMPLVLIST_`date +%Y%m%d`.tmp"
cp /dev/null $TMPLVLIST

#echo $VGNAMEP1
#Example 31vg12

PVG=${VGNAMEP1}vg
#LV list
ssh ${HOST} "/usr/sbin/lsvg -o | grep -v rootvg | xargs -i lsvg -l {} " | awk {'print $1'} > $TMPLVLIST

#echo "INFO: RAW VG List"
cat  $TMPLVLIST | grep -v -x LV > $AVFFILE 
