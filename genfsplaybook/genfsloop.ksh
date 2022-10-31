#!/bin/ksh
#Version=1.0.0
#Date=2022-10-13
#1 input file from spreadsheet

DAUTOYAML=/tmp
TMSTAMP=`date +%d%m%Y_%H%M%S`
FYAML=CrFS_${TMSTAMP}.yaml

ParmA=$1
if [[ -z $ParmA ]]
then
   echo "ERR: genfsloop.ksh requires input 1 spreadsheet."
   echo "1st input does not exist."
   echo "Example: genfsloop.ksh /home/ansiadm/yourfs.txt"
   echo "Press enter to exit:"
   read
   exit 91
fi

#Remote host array from 1 input
set -A ARRHOST

NORHOST=`cat $ParmA | grep -v "Expected File System Size" | awk {'print $9'} | sort - | uniq  |wc -l`

RFILEPNT=$NORHOST

#LOOP pointer
HEADPNT=1
echo "filesystems_add:" > $DAUTOYAML/$FYAML
while [[ $RFILEPNT -ne 0 ]]
do 
	#cat $ParmA | awk {'print $9'} | sort - | uniq | head -${HEADPNT} | tail -1
	echo "HEADPNT is $HEADPNT"
	ARRHOST[$HEADPNT]=`cat $ParmA | grep -v "Expected File System Size" | awk {'print $9'} | sort - | uniq | head -${HEADPNT} | tail -1`
	echo ${ARRHOST[$HEADPNT]}
	#Debug echo ${ARRHOST[$HEADPNT]}

	/home/ansiadm/handover/genfsplaybook/genfsyaml.ksh ${ARRHOST[$HEADPNT]} /home/ansiadm/handover/genfsplaybook/$ParmA $TMSTAMP

	HEADPNT=`expr $HEADPNT + 1`
	RFILEPNT=`expr $RFILEPNT - 1`
done
