#!/bin/bash

SRC=$1
DEST=$2
ARG=$3

#Ensuring there are 3 variables
if [ $# -ne 3 ]; then 
	echo "Enter Valid Number of Arguements"
	exit 1
fi

#Checking the existence of source directory

if [ ! -d "$SRC" ]; then 
	echo "Source Directory doesn't exist"
	exit 0
fi

#Globbing to check the directory with given extension 
shopt -s nullglob
files=("$SRC"*"$ARG")

#Checking whether destination exists

if [ ! -d "$DEST" ]; then
	echo "Destination Directory doesn't exist"
	exit 0
fi

#Checking whether source directory contains files with the given extension
if [ ${#files[@]} -eq 0 ]; then
	echo "Source Directory Doesn't Conatain $ARG files"
	exit 1
fi


#Exporting BACK_UP COUNT and tracking number of files backedup

export BACKUP_COUNT=0
TOTAL_SIZE=0

 #Bachup process

for file in "${files[@]}"; do
	filename=$(basename "$file")
	dest_file="$DEST$filename"

	if [ -f  "$dest_file" ]; then
		if [ "$file" -nt "$dest_file" ]; then
			#overwriting if file already exists in backup folder but older
			cp "$file" "$dest_file"
			((BACKUP_COUNT++))
			size=$(stat -c %s "$file")
			((TOTAL_SIZE+=size))
		fi
		else
			cp "$file" "$dest_file"
			((BACKUP_COUNT++))
			size=$(stat -c %s "$file")
			((TOTAL_SIZE+=size))
	fi
done

echo "Files to be backed up:"
echo "---------------------"


#Printing the names and sizes of files being backedup

for file in "${files[@]}";do
	size=$(stat -c %s "$file")
	echo "$(basename "$file") - "$size" bytes"
done

echo "---------------------"

#Report file generation

REPORT_FILE=""$DEST"backup_report.log"

{
	echo "Backup Summary Report"
	echo "---------------------"
	echo "Total files processed : ${#files[@]}"
	echo "Total files backed up : $BACKUP_COUNT"
	echo "Total size backed up  : $TOTAL_SIZE bytes"
	echo "Backedup directory    : $DEST"
} > "$REPORT_FILE"
echo "Backup Completed Successfully."
echo "Report saved to $REPORT_FILE"
