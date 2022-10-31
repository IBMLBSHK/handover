#!/bin/ksh
#Version=1.0.0
#Date=2022-03-15
#1 input file

#fsadd.txt
DAUTOYAML=/tmp
#FAUTOYAML=$1_filesystems.yaml

#Parameter 3 is TIMESTAMP
TMSTAMP=$3
FAUTOYAML=$1_filesystems_${TMSTAMP}.yaml
FYAML=CrFS_${TMSTAMP}.yaml


ParmA=$1
#echo "ParmA is : $ParmA"
echo ""

if [[ -z $ParmA ]]
then
   echo "ERR: genfsyaml.ksh requires input 1 remote hostname and 2 input spreadsheet."
   echo "1st remote hostname does not exist."
   echo "Example: genfsyaml.ksh cdcsrv82 /home/ansiadm/yourfs.txt"
   echo "Press enter to exit:"
   read
   exit 91
fi
REHOST=$ParmA


#ParamB input from spreadsheet file

ParmB=$2
#echo "ParmB is : $ParmB"
#echo ""

if [[ -z $ParmB || ! -e $ParmB ]]
then
   echo "ERR: genfsyaml.ksh requires input 1 remote hostname and 2 input spreadsheet."
   echo "2nd input file (spreadsheet file) does not exist."
   echo "Example: genfsyaml.ksh cdcsrv82 /home/ansiadm/yourfs.txt"
   echo "Press enter to exit:"
   read
   exit 92
fi

#-------------------------------------------------
#Check remote VG free size
#-------------------------------------------------
CHVGFILE=/tmp/${REHOST}_chkvgfree_${TMSTAMP}.tmp

INSTPATH=/home/ansiadm/handover/genfsplaybook
$INSTPATH/chkvgfree.ksh $REHOST $CHVGFILE $TMSTAMP
#-------------------------------------------------
#Check existing mount
#-------------------------------------------------
CHFSFILE=/tmp/${REHOST}_chfs_${TMSTAMP}.tmp
$INSTPATH/chkfs.ksh $REHOST $CHFSFILE $TMSTAMP

FAUTOYAML=${REHOST}_add_filesystems_${TMSTAMP}.yaml

#echo "Debug filesystems_add:" > $DAUTOYAML/$FAUTOYAML
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
SSPNT=$LENVGFREE
HEADPNT=1
while [[ $SSPNT -ne 0 ]]
do
        echo "[$HEADPNT] ARRVGFREE:"
        echo ${ARRVGFREE[$HEADPNT]}
        HEADPNT=`expr $HEADPNT + 1`
        SSPNT=`expr $SSPNT - 1 `

done

#--------------------------------------------------
#Create Add YAML
LENCRFS=`cat $ParmB | grep $REHOST | grep Add | wc -l`
CRRWAPNT=$LENCRFS
CUR1STPNT=1
HEADPNT2=1
CURFREE=`echo ${ARRVGFREE[$CUR1STPNT]} | awk {'print $1'}`
NOAVALV=`echo ${ARRVGFREE[$CUR1STPNT]} | awk {'print $3'}`
echo "NOAVALV: $NOAVALV"

#LOOP about FS DATA LINE

while [[ $LENCRFS -ne 0 ]]
do
#LOOP pointer

FSDATALNE=`cat $ParmB | grep $REHOST | grep Add | awk {'print $5,$4,$2,$3,$6,$7,$8,$9'} | sort  -n | head -${HEADPNT2} | tail -1`

CRDEV=`echo $FSDATALNE | awk {'print $1'}"`
if [[ -z $CRDEV ]]
then 
	echo "ERR: Filesystem is empty."
	echo "ERR: Failed to generate $FAUTOYAML"
	echo "Press enter key to quit."
	read 
	rm $DAUTOYAML/$FAUTOYAML
	break
	#exit 99
fi

CRSIZE=`echo $FSDATALNE | awk {'print $2'}"`
if [[ $CRSIZE -lt 0 || -z $CRSIZE ]]
then
	echo "ERR: Filesystem size is invalid."
	echo "ERR: Failed to generate $FAUTOYAML"
	echo "Press enter key to quit."
	read 
        rm $DAUTOYAML/$FAUTOYAML
	break
        #exit 99
fi

CRACODE=`echo $FSDATALNE | awk {'print $3'}"`
if [[ -z $CRACODE ]]
then 
        echo "ERR: Alert Code is empty."
        echo "ERR: Failed to generate $FAUTOYAML"
        echo "Press enter key to quit."
        read
        rm $DAUTOYAML/$FAUTOYAML
	break
        #exit 99
fi


CRALEV=`echo $FSDATALNE | awk {'print $4'}"`
if [[  $CRALEV -lt 0 || -z $CRALEV ]]
then
	echo "ERR: Email alert level is empty."
        echo "ERR: Failed to generate $FAUTOYAML"
        echo "Press enter key to quit."
        read
        rm $DAUTOYAML/$FAUTOYAML
	break
        #exit 99
fi

CRUSRGRP=`echo $FSDATALNE | awk {'print $5'}"`
CRUSR=`echo $CRUSRGRP | awk -F ":" {'print $1'}"`
if [[ -z $CRUSR ]]
then
        echo "ERR: User is empty."
        echo "ERR: Failed to generate $FAUTOYAML"
        echo "Press enter key to quit."
        read
        rm $DAUTOYAML/$FAUTOYAML
	break
        #exit 99
fi

CRGRP=`echo $CRUSRGRP | awk -F ":" {'print $2'}"`
if [[ -z $CRGRP ]]
then 
        echo "ERR: Group is empty."
        echo "ERR: Failed to generate $FAUTOYAML"
        echo "Press enter key to quit."
        read
        rm $DAUTOYAML/$FAUTOYAML
	break
        #exit 99
fi

CRPLEV=`echo $FSDATALNE | awk {'print $6'}"`
if [[ -z $CRPLEV ]]
then 
	echo "ERR: Pager alert level is empty."
        echo "ERR: Failed to generate $FAUTOYAML"
        echo "Press enter key to quit."
        read
        rm $DAUTOYAML/$FAUTOYAML
	break
        #exit 99
fi

CRLVNM=`echo $FSDATALNE | awk {'print $7'}"`
if [[ -z $CRLVNM ]]
then
	echo "ERR: LV Name is empty."
	echo "ERR: Failed to generate $FAUTOYAML"
        echo "Press enter key to quit."
        read
        rm $DAUTOYAML/$FAUTOYAML
	break
        #exit 99
fi

CRHOST=`echo $FSDATALNE | awk {'print $8'}"`
if [[ -z $CRHOST ]]
then
	echo "ERR: Hostname is empty."
	echo "ERR: Failed to generate $FAUTOYAML"
	echo "Press enter key to quit."
	read
	rm $DAUTOYAML/$FAUTOYAML
	break
	#exit 99
fi


CRVG=`echo ${ARRVGFREE[$CUR1STPNT]} | awk {'print 2'}`
echo "INFO: Plan to create LV device and Filesystem: $CRLVNM and $CRDEV"
echo "INFO: Plan to create filesystem size (MB) : $CRSIZE"

                echo "INFO: Estimate VG Free size (MB): $CURFREE"
                if [[ $CURFREE -gt $CRSIZE && $NOAVALV -gt 0 ]]
                then
                        #echo "Use Current VG"
                        #Set YAML
                        VGNAME=`echo ${ARRVGFREE[$CUR1STPNT]} | awk {'print $2'}`
                        CURFREE=`expr $CURFREE - $CRSIZE`
			NOAVALV=`expr $NOAVALV - 1`
			#echo "INFO: VG Size (MB) and Name is = ${ARRVGFREE[$CUR1STPNT]}"
			echo "INFO: Plan to create Filesystem at VG: $VGNAME"
                        echo "INFO: Estimate after created Filesystem Free Size (MB) = $CURFREE"
			echo "INFO: Estimate after created Raw device available LV no.: $NOAVALV"
			echo ${CRDEV}
			#check existing mount
			cat $CHFSFILE | grep ^${CRDEV} > /dev/null
			if [[ $? -eq 0 ]]
			then 
				echo "ERR: ${CRDEV} or child mount existed."
				echo "ERR: Please check ${REHOST} mount points."
				echo "ERR: $DAUTOYAML/$FAUTOYAML will be removed."
				echo "ERR: Failed to generate $FAUTOYAML"
				read
				rm $DAUTOYAML/$FAUTOYAML
				
				exit 98
			fi
			echo " - filesystem: ${CRDEV}" >> $DAUTOYAML/$FAUTOYAML
                        echo "   lv: $CRLVNM" >> $DAUTOYAML/$FAUTOYAML
                        #VGNAME=`echo ${ARRVGFREE[$CUR1STPNT]} | awk {'print $2'}`
                        echo "   vg: $VGNAME" >> $DAUTOYAML/$FAUTOYAML
                        echo "   user: $CRUSR" >> $DAUTOYAML/$FAUTOYAML
                        echo "   group: $CRGRP" >> $DAUTOYAML/$FAUTOYAML
                        echo "   size: ${CRSIZE}M" >> $DAUTOYAML/$FAUTOYAML
			echo "   alert_project_code: ${CRACODE}" >> $DAUTOYAML/$FAUTOYAML
			echo "   email_alert_level: ${CRALEV}" >> $DAUTOYAML/$FAUTOYAML
                        echo "   pager_alert_level: ${CRPLEV}" >> $DAUTOYAML/$FAUTOYAML
                        echo "   host: ${CRHOST}" >> $DAUTOYAML/$FAUTOYAML

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
                        #May need to adjust the FS point
                        HEADPNT2=`expr $HEADPNT2 - 1`
                        LENCRFS=`expr $LENCRFS + 1`
                fi
        echo ""


        HEADPNT2=`expr $HEADPNT2 + 1`
        LENCRFS=`expr $LENCRFS - 1`
done
cat $DAUTOYAML/$FAUTOYAML >> $DAUTOYAML/$FYAML
#echo "INFO: filesystems.yaml has been created successfully at : $DAUTOYAML/$FAUTOYAML"
echo "INFO: filesystems.yaml has been created successfully at : $DAUTOYAML/$FYAML"

#END of FS DATA LINE
