#!/bin/ksh

#Input ParmA
#Input ParmB

#ParamA autogen YAML
#/home/root/hkha/rawlvs.yaml

ParmA=$1
echo "ParmA is : $ParmA"
echo ""

if [[ -z $ParmA ]]
then
   echo "ERR: vergenrawlvyaml.ksh requires input 1 and 2."
   echo "input 1 is path and file of chkvgfree"
   echo "Example: vergenrawlvyaml.ksh <PATH>/rawlvs.yaml <PATH>/rawlvsrc.txt"

   echo "Press enter to exit:"
   read
   exit 91
fi

ParmB=$2
echo "ParmB is : $ParmB"
echo ""

if [[ -z $ParmB ]]
then
   echo "ERR: vergenrawlvyaml.ksh requires input 1 and 2."
   echo "input 2 is path and file of spreadsheet file"
   echo "Example: vergenrawlvyaml.ksh <PATH>/rawlvs.yaml <PATH>/rawlvsrc.txt"

   echo "Press enter to exit:"
   read
   exit 92
fi



#ParamB input from spreadsheet file
#/home/root/hkha/rawlvsrc.txt

ParmB=$2

NOYAMLRAWLV=`cat $ParmA | grep user |  wc -l`

INPUTRAWLV=`cat $ParmB | grep  Add | wc -l`

if [[ $NOYAMLRAWLV -eq $INPUTRAWLV ]]
then 
	echo "INFO: Verification passed."
else
	echo "ERR: Number of $ParmA and $ParmB"
fi


#Verify number of raw device to be created


#END of RAW DATA LINE
