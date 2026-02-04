#!/bin/bash

INPUT_FILE="$1"
OUTPUT_FILE="output.txt"

if [ $# -ne 1 ]; then

	echo "File: $0 <input_file>"
	exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
	echo "File not found!"
	exit 1
fi


awk '

	/"frame.time"/ {
		frame_time=$0
	}

	/"wlan.fc.type"/ {
		wlan_type=$0
	}
	
	/"wlan.fc.subtype"/ {
		wlan_subtype=$0

		print frame_time >> "output.txt"
		print wlan_type >> "output.txt"
		print wlan_subtype >> "output.txt"
		print "" >> "output.txt"

		frame_time = wlan_type = wlan_subtype = ""
}
' "$INPUT_FILE"

