#!/bin/ksh

ParmA=$1
if [[ -z $ParmA ]]
then
   echo "ERR: chkfs.ksh requires timestamp remote hostname"
   echo "Please input timestamp"
   echo "Example: chkvgfree.ksh cdcsrv82 /tmp/chkfs_20220209.tmp 14102022_104104"
   echo "Press enter to exit."
   read
   exit 92
fi


ParmB=$2

if [[ -z $ParmB ]]
then
   echo "ERR: chkfs.ksh requires timestamp remote hostname"
   echo "Please input timestamp"
   echo "Example: chkvgfree.ksh cdcsrv82 /tmp/chkfs_20220209.tmp 14102022_104104"
   echo "Press enter to exit:"
   read
   exit 92
fi

ParmC=$3
if [[ -z $ParmC ]]
then
   echo "ERR: chkfs.ksh requires timestamp remote hostname"
   echo "Please input timestamp"
   echo "Example: chkvgfree.ksh cdcsrv82 /tmp/chkfs_20220209.tmp 14102022_104104"
   echo "Press enter to exit:"
   read
   exit 92
fi



#Get hostname last 2 char
HOST=$ParmA
TMPFSLIST=/tmp/${HOST}_TMPFSLIST_$ParmC.tmp
cp /dev/null $TMPFSLIST
ssh ${HOST} "df" | awk {'print $7'} > $TMPFSLIST
cat $TMPFSLIST > $ParmB
