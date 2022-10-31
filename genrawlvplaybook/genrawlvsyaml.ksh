#!/bin/ksh
#2 input files
#1st output from chkvgfree.ksh 
#2nd input from rawlvsrc.txt
#To get the free MB and VG name

#Define installation path
INSTPATH=/home/ansiadm/handover/genrawlvplaybook

#Input ParmA <rmt hostname> 
#Input ParmB <genrawlvsyaml.ksh auto define output YAML> 

#ParamA output of chkvgfree.ksh
#/tmp/pf_nim_210_chkvgfree_20220209.tmp

ParmA=$1
#echo "ParmA is : $ParmA"
echo ""

if [[ -z $ParmA ]] 
then
   echo "ERR: genrawlvsyaml.ksh requires input 1 remote hostname and 2 input spreadsheet."
   echo "1st remote hostname does not exist."
   echo "Example: genrawlvsyaml.ksh cdcsrv82 /home/ansiadm/rawlvsrc.txt" 
   echo "Press enter to exit:"
   read 
   exit 91
fi
REHOST=$ParmA


#ParamB input from spreadsheet file
#/home/root/hkha/rawlvsrc.txt

ParmB=$2
#echo "ParmB is : $ParmB"
#echo ""

if [[ -z $ParmB || ! -e $ParmB ]]
then   
   echo "ERR: genrawlvsyaml.ksh requires input 1 remote hostname and 2 input spreadsheet."
   echo "2nd input file (spreadsheet file) does not exist."
   echo "Example: genrawlvsyaml.ksh cdcsrv82 /home/ansiadm/rawlvsrc.txt" 
   echo "Press enter to exit:"
   read 
   exit 92
fi

#-------------------------------------------------
#PreChecks
#Check remote VG free size 
#CHVGFILE is script output file
#-------------------------------------------------
CHVGFILE=/tmp/${REHOST}_chkvgfree_`date +%Y%m%d`.tmp
CHLVFILE=/tmp/${REHOST}_chklvs_`date +%Y%m%d`.tmp

#/home/ansiadm/rawlv/chkvgfree.ksh $REHOST $CHVGFILE
$INSTPATH/chkvgfree.ksh $REHOST $CHVGFILE
$INSTPATH/chklvs.ksh $REHOST $CHLVFILE

echo "INFO: chkvgfree.ksh Output file is ${CHVGFILE}"
echo "INFO: chklvs.ksh Output file is ${CHLVFILE}"


DAUTOYAML=/tmp
FAUTOYAML=${REHOST}_rawlvs.yaml

echo "rawlvs_add:" > $DAUTOYAML/$FAUTOYAML
#--------------------------------------------------
LENVGFREE=0
#Line of the input file
LENVGFREE=`cat $CHVGFILE |wc -l`

#FreeSize VG array
set -A ARRVGFREE

#head -1 | tail -1
#head -2 | tail -1

#READ file pointer
RFILEPNT=$LENVGFREE
#LOOP pointer
HEADPNT=1
while [[ $RFILEPNT -ne 0 ]]
do 
	ARRVGFREE[$HEADPNT]=`cat $CHVGFILE | sort -n -r  | head -${HEADPNT} | tail -1`
        HEADPNT=`expr $HEADPNT + 1`
        RFILEPNT=`expr $RFILEPNT - 1`
done
#--------------------------------------------------



#--------------------------------------------------

#--------------------------------------------------
SSPNT=$LENVGFREE
HEADPNT=1
while [[ $SSPNT -ne 0 ]]
do
        echo "INFO: [$HEADPNT] VGName ARRVGFREE NoAvaLV:"
	echo ${ARRVGFREE[$HEADPNT]}
        echo ""
        HEADPNT=`expr $HEADPNT + 1` 
        SSPNT=`expr $SSPNT - 1 `

#Output
#ARRVGFREE [1]:
#207616 nim210vg11
#ARRVGFREE [2]:
#20400 da10vg01
#ARRVGFREE [3]:
done

#--------------------------------------------------
#Create Add YAML
LENCRRAW=`cat $ParmB | grep Add | wc -l`
CRRWAPNT=$LENCRRAW
CUR1STPNT=1
HEADPNT2=1
CURFREE=`echo ${ARRVGFREE[$CUR1STPNT]} | awk {'print $1'}`
NOAVALV=`echo ${ARRVGFREE[$CUR1STPNT]} | awk {'print $3'}`
echo "NOAVALV: $NOAVALV"

#LOOP about RAW DATA LINE

while [[ $LENCRRAW -ne 0 ]]
do
#LOOP pointer
RAWDATALNE=`cat $ParmB | grep Add | awk {'print $4,$3,$5,$2'} | sort  -n -r | head -${HEADPNT2} | tail -1`
CRSIZE=`echo $RAWDATALNE | awk {'print $1'}"`
CRDEV=`echo $RAWDATALNE | awk {'print $2'}"`
CRUSR=`echo $RAWDATALNE | awk {'print $3'}"`
CRGRP=`echo $RAWDATALNE | awk {'print $4'}"`
CRVG=`echo ${ARRVGFREE[$CUR1STPNT]} | awk {'print 2'}`


echo "INFO: Create raw device: $CRDEV"
echo "INFO: Create raw size (MB) : $CRSIZE"
#Output
#Size  device              user group
#10240 /dev/rrisaic_sp1tm1 risadm ris
#10240 /dev/rrisaic_sp1da99 risadm ris

        #LOOP about FREE VG SIZE
        #SET ARRVGPNT
        
        
        	#CURFREE Free size calculate vs CRRAW Filesystem
        	#if all used free then CUR1stPnt add 1
                echo "INFO: Current VG Free size: $CURFREE and Create Raw Size $CRSIZE (MB)."
		#echo $CURFREE 
 	        #echo $CRSIZE
       		if [[ $CURFREE -gt $CRSIZE && $NOAVALV -gt 0  ]] 
		then
        		#echo "Use Current VG"
                	#Set YAML
			
			CURFREE=`expr $CURFREE - $CRSIZE`
			NOAVALV=`expr $NOAVALV - 1`
			echo "INFO: Estimate after created Raw device Free Size: $CURFREE" 
			echo "INFO: Estimate after created Raw device available LV no.: $NOAVALV" 
			###echo "INFO: VG Name is : ${ARRVGFREE[$CUR1STPNT]}"

			_crdev=`echo $CRDEV | cut -d'/' -f 3`
			cat $CHLVFILE | grep -x ${_crdev} > /dev/null 
			#To check existing LV avoid duplicated LV name
			if [[ $? -eq 0 ]]
			then
				echo "ERR: ${_crdev} already existed. Please review input file ${ParmB} lv name: ${_crdev}."
				echo "ERR: Failed to generate $FAUTOYAML"
                                echo "Press enter key to quit."
				read
				rm $DAUTOYAML/$FAUTOYAML
				exit 98
			fi
			echo " - rawlv: $_crdev" >> $DAUTOYAML/$FAUTOYAML
			VGNAME=`echo ${ARRVGFREE[$CUR1STPNT]} | awk {'print $2'}`
                        echo "   vg: $VGNAME" >> $DAUTOYAML/$FAUTOYAML
			echo "   size: ${CRSIZE}M" >> $DAUTOYAML/$FAUTOYAML
			echo "   user: $CRUSR" >> $DAUTOYAML/$FAUTOYAML
			echo "   group: $CRGRP" >> $DAUTOYAML/$FAUTOYAML
			echo "" >> $DAUTOYAML/$FAUTOYAML



        	else
			echo "Search next VG"
			CUR1STPNT=`expr $CUR1STPNT + 1`
                        echo $CUR1STPNT
                        echo "Next VG Name is : ${ARRVGFREE[$CUR1STPNT]}"
			echo "CUR1STPNT is :" 
			echo $CUR1STPNT
			CURFREE=`echo ${ARRVGFREE[$CUR1STPNT]} | awk {'print $1'}`
                        NOAVALV=`echo ${ARRVGFREE[$CUR1STPNT]} | awk {'print $3'}`
			#No more VG available
			if [[ -z ${ARRVGFREE[$CUR1STPNT]} ]]
			then
				
				echo "ERR: $DAUTOYAML/$FAUTOYAML will be removed."
				echo "ERR: No more VG free can use!"
				echo "ERR: Failed to generate $FAUTOYAML"
				echo "Press enter key to quit."
				read
                                rm $DAUTOYAML/$FAUTOYAML
				exit 99
			fi
			#May need to adjust the RAW point
                        HEADPNT2=`expr $HEADPNT2 - 1`
			LENCRRAW=`expr $LENCRRAW + 1`
		fi 
	echo ""


	HEADPNT2=`expr $HEADPNT2 + 1`
	LENCRRAW=`expr $LENCRRAW - 1`
done
echo "INFO: rawlvs.yaml has been created successfully at : $DAUTOYAML/$FAUTOYAML"
#END of RAW DATA LINE
