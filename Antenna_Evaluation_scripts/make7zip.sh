#!/bin/sh

INPUT="input.txt"

chmod 777 list.txt
chmod 777 mkdir.txt
rm list.txt
rm mkdir.txt

if [ $# -ne 1 ];then
		echo "ERROR. Usage make7zip.bash Output_File_Name"
		echo "e.g. make7zip.bash Project_Name"
		exit
fi
echo "Ensure that input.txt file contains all the required data as explained into it."
echo " Press y to continue or n to exit."
read char
echo "***************Reading Input File***************************"
if [ $char != 'y' ] && [ $char != 'Y' ];then
	exit
else
	#READ input.txt 1st and get all the input ready to use.
	while read -r line
	do 
		if [ ${line:0:7} == "include" ];then    # Is it include DIR?
			INCLUDE+=" ${line:8}"
		elif [ ${line:0:7} == "exclude" ];then	 # Is it exclude DIR?
			EXCLUDE+=" ${line:8}"
		elif [ ${line:0:1} != "#" ] && [ ${line:0:1} != " " ] && [ ${line:0:1} != "\n" ];then         # Is it not COMMENT, then File Name or Suffix?
			FILE+=" -o -name \"*${line}\""
		fi
	done < $INPUT
	FILE="${FILE:3}"

	echo "*****************Listing "$FILE" from following: *********************************"
	echo $INCLUDE
	for DIR in $INCLUDE
	do
		DIR="./${DIR}"
		command="find $DIR $FILE >> \"list.txt\""
		eval $command
	done
	echo "********************Performing Internal Operation*******************************************"
	for (( i=0; i<${#EXCLUDE}; i++ ));
	do
		if [ ${EXCLUDE:${i}:1} == "." ] || [ ${EXCLUDE:${i}:1} == "/" ];then
			if [ ${EXCLUDE:((${i}-1)):1} != "\\" ];then
				EXCLUDE=${EXCLUDE:0:${i}}"\\"${EXCLUDE:${i}}
			fi
		fi
	done	
	echo "*******************Excludin files from following, If any***********************************"
	echo $EXCLUDE
	for EX in $EXCLUDE
	do
		sed -i "/$EX/d" "list.txt"
	done	
	echo "******************Creating dummy directories***********************************************"
	chmod 777 list.txt
	cp list.txt mkdir.txt
	sed -i "s/\(^.*\/\).*$/\1/g" mkdir.txt
	chmod 777 mkdir.txt
	sed -i "s/\(^.\)\(.*$\)/\1\/temp\2/g" mkdir.txt
	chmod 777 mkdir.txt
	sort mkdir.txt | uniq > dir.txt
	while read -r DIR
	do 
		mkdir -p $DIR 
	done < "dir.txt"	
	echo "****************Copying files to be Zipped*************************************************"
	while read -r src
	do 
		dest=${src:0:2}"temp/"${src:2}
		cp $src $dest
	done < "list.txt"	
	echo "****************Zipping*******************************************************************"
	zip="${1}.7z"
	rm $zip
	cd ./temp/
	command="7z a ../$zip ."
	eval $command
	echo "*************************************************************************"
	echo "*Please COMPARE File Count listed above with files present into list.txt*"
	echo "*************************************************************************"
	cd ..
	chmod 777 mkdir.txt
	chmod 777 dir.txt
	rm mkdir.txt
	rm dir.txt
	rm -rf temp
fi

