#!/bin/ksh
#Version=1.0.0
#Date=2022-02-22
#1 input file 

#usersadd.txt
DAUTOYAML=/tmp
FAUTOYAML=users.yaml.tmp


ParmA=$1
echo "Input user text file is : $ParmA"
echo ""

if [[ -z $ParmA ]]
then 
	echo "ERR: genusersyaml.ksh requires 1 input file user info."
        echo "input file copy from spreadsheet"
        echo "Press enter to exit:"
	read 
	exit 91
fi
 
echo "users_add:" > $DAUTOYAML/$FAUTOYAML

#Determine the number of user to create from input file
#Note: awk -F '   ' is tab instead of spaces
LENADDACCT=0
LENADDACCT=`cat $1 | awk -F '	' {'print $2'} | grep Add | wc -l`
RACCTPNT=$LENADDACCT
echo "Info: Total number of user to be added: $LENADDACCT"
set -A ARRADDACT
set -A ARRLINEADD
HEADPNT=1
while [[ $RACCTPNT -ne 0 ]]
do 

                echo "Processing: $HEADPNT of $LENADDACCT"
                echo ""
		ARRADDACT[$HEADPNT]=`cat $ParmA |grep Add | head -${HEADPNT} | tail -1`
		
		#Extract elements 12
                #1 AcctName
                #2 Action discard
                #3 Project Code
                #4 Description
                #5 Filesystem Size
                #6 Home
                #7 AcctLock
                #8 Email
                #9 PGroup
                #10 OGroups
                #11 UID
                #12 Passwd

		#echo "ARRADDACT[$HEADPNT] is ${ARRADDACT[$HEADPNT]}"
		ACCNAME=`cat $ParmA |grep Add | head -${HEADPNT} | tail -1 | awk -F '	' {'print $1}`
		if [[ -z $ACCNAME ]]
		then
			echo "ERR: Username cannot be null."
			echo "Press enter to exit:"
			read
			exit 92
		fi
		# Reserved `cat $ParmA |grep Add | head -${HEADPNT} | tail -1 | awk -F '	' {'print $2}`
		PRJCODE=`cat $ParmA |grep Add | head -${HEADPNT} | tail -1 | awk -F '	' {'print $3}`
	        DESC=`cat $ParmA |grep Add | head -${HEADPNT} | tail -1 | awk -F '	' {'print $4}`
		FSIZE=`cat $ParmA |grep Add | head -${HEADPNT} | tail -1 | awk -F '	' {'print $5}`
		HOMEFLD=`cat $ParmA |grep Add | head -${HEADPNT} | tail -1 | awk -F '	' {'print $6}`
		if [[ -z $HOMEFLD ]]
                then
			echo "ERR: User home folder cannot be null."
			echo "Press enter to exit:"
			read 
			exit 93
		fi 
		ACCLCK=`cat $ParmA |grep Add | head -${HEADPNT} | tail -1 | awk -F '	' {'print $7}`
		if [[ $ACCLCK = "N" || $ACCLCK = "n" || $ACCLCK = "No" || $ACCLCK = "no" || $ACCLCK = "NO" ]]
		then 
			ACCLCK="false"
		else
			ACCLCK="true"
		fi
		EMAIL=`cat $ParmA |grep Add | head -${HEADPNT} | tail -1 | awk -F '	' {'print $8}`
		PGRP=`cat $ParmA |grep Add | head -${HEADPNT} | tail -1 | awk -F '	' {'print $9}`
		OGRPS=`cat $ParmA |grep Add | head -${HEADPNT} | tail -1 | awk -F '	' {'print $10}`
		OGRPS=`echo $OGRPS | grep -i [a-z]`


		UID=`cat $ParmA |grep Add | head -${HEADPNT} | tail -1 | awk -F '	' {'print $11}`
		if [[ -z $UID ]]
		then 
			echo "ERR: User ID cannot be null."
			echo "Press enter to exit:"
                        read
                        exit 93
		fi
		TEMPASS=`cat $ParmA |grep Add | head -${HEADPNT} | tail -1 | awk -F '	' {'print $12}`
		if [[ -z $TEMPASS ]]
		then 
			echo "ERR: Password cannot be null."
			echo "Press enter to exit:"
                        read
                        exit 93
		fi
                PASS=`/opt/freeware/bin/ansible all -i localhost, -m debug -a "msg={{'$TEMPASS' | password_hash('sha512')}}" | grep "msg" | awk -F ": " {'print $2'}`
		

		echo "  - name: \"$ACCNAME\"" >> $DAUTOYAML/$FAUTOYAML
		#Need to encrypted
		echo "    password: $PASS" >> $DAUTOYAML/$FAUTOYAML
		echo "    manager_email: \"$EMAIL\"" >> $DAUTOYAML/$FAUTOYAML
		echo "    attributes:" >> $DAUTOYAML/$FAUTOYAML
		echo "      account_locked: \"$ACCLCK\"" >> $DAUTOYAML/$FAUTOYAML
		echo "      pgrp: \"$PGRP\"" >> $DAUTOYAML/$FAUTOYAML

		if [[ $OGRPS != "--" && ! -z $OGRPS ]]	
		then
			echo "      groups: \"$OGRPS\"" >> $DAUTOYAML/$FAUTOYAML
		fi

		echo "      home: \"$HOMEFLD\"" >> $DAUTOYAML/$FAUTOYAML
		echo "      id: \"$UID\"" >> $DAUTOYAML/$FAUTOYAML
			


		HEADPNT=`expr $HEADPNT + 1`
		RACCTPNT=`expr $RACCTPNT - 1`
done
echo "Info: Used input file $ParmA to create $DAUTOYAML/$FAUTOYAML"
