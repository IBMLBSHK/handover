#!/bin/ksh

ParmA=$1
if [[ -z $ParmA ]]
then
   echo "ERR: chkvgfree.ksh requires 2 inputs 1st remote hostname and output path for genrawlvsyaml.ksh"
   echo "1st input is remote username"
   echo "Example: chkvgfree.ksh cdcsrv82 /tmp/chkvgfree_20220209.tmp"
   echo "Press enter to exit."
   read
   exit 91
fi


ParmB=$2

if [[ -z $ParmB ]]
then
   echo "ERR: chkvgfree.ksh requires inputs remote hostname"
   echo "Please input remote hostname"
   echo "Example: chkvgfree.ksh cdcsrv82 /tmp/chkvgfree_20220209.tmp"
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

#tmp file for array-vg-free chkvgfree.ksh
AVFFILE="/tmp/${HOST}_chkvgfree_`date +%Y%m%d`.tmp"
cp /dev/null $AVFFILE

#echo $VGNAMEP1
#Example 31vg12

PVG=${VGNAMEP1}vg

#VG list
#ssh ansiadm@ansible9 "/usr/sbin/lsvg -o" | grep $PVG | grep -v rootvg
VGLIST=`ssh ${HOST} "/usr/sbin/lsvg -o" | grep $PVG | grep -v rootvg`

echo "INFO: Candidate VG List"
echo $VGLIST

set -A ARRVG $VGLIST
echo "INFO: Number of candidate VG"
ARRSIZE=`echo ${#ARRVG[@]}`
echo $ARRSIZE

#Create VG and free space array ARRVGFREE
#Ensure Array is greater than 0
if [[ $ARRSIZE -ne 0 ]] 
then
	set -A ARRVGFREE
	PNTER=0
	while [[ $PNTER -lt $ARRSIZE ]]
		do
			#echo "PNTER: $PNTER" 
			#VG Name
			#Get VGName 
			#echo ${ARRVG[$PNTER]}
                        ARPNTVG=${ARRVG[$PNTER]}
			#echo "DB:"
			#echo $ARPNTVG
			#Get Free size
                        ARPNTFREE=`ssh ${HOST} "lsvg $ARPNTVG" | grep FREE | awk -F ":" {'print $3'} | awk {'print $2'} |  sed -e 's/(//g'`
			ARRVGFREE[$PNTER]="$ARPNTVG $ARPNTFREE"
                        #Get Free No. Avaliable LV
                        MAXLV=`ssh ${HOST} "lsvg $ARPNTVG" | grep "MAX LVs" | grep -v OPEN | awk -F ":" {'print $2'} | awk {'print $1'}  |  sed -e 's/(//g'`
                        #echo "MAXLV is $MAXLV"
                        #In use No. LV
                        USEDLV=`ssh ${HOST} "lsvg $ARPNTVG" | grep  "LVs" | grep -v MAX | grep -v OPEN | awk -F ":" {'print $2'} | awk {'print $1'}  |  sed -e 's/(//g'`
			#echo "USEDLV is $USEDLV"
                        AVALV=`expr $MAXLV - $USEDLV` 
			#echo "AVALV is : $AVALV"
			#Create VG name free arrany
			#ARRVGFREE[$PNTER]=`echo $ARPNTFREE " " $ARPNTVG`
			ARRVGFREE[$PNTER]=`echo $ARPNTFREE " " $ARPNTVG " " $AVALV`
			echo ${ARRVGFREE[$PNTER]} >> $AVFFILE
			#echo $ARNAME
			PNTER=`expr $PNTER + 1`
                done	
		echo "INFO: chkvgfree.ksh Output file:  $AVFFILE"
		echo "INFO:"
                echo "FREE(MB)  VGNAME  NoAvaLV:"
		echo "`cat $AVFFILE`"
else
	#No VG can be used
	echo "ERR: No VG available to use!"
	echo "Press enter to quit"
	read
	exit 90
fi
