#!/bin/bash

LOG_ERROR="errors.log"

log_error(){
	local info="$1"
	echo "ERROR: $info" >> "$LOG_ERROR"
	echo "ERROR: $info" >&2

}

show_help() {
cat << EOF
Usage: $0 [-d directory] [-f file] [-k keyword]
-d : Recursive search in directory
-f : Search in a specific file
-k : The keyword to find
--help : Show help
EOF
}

#recursive search
recursive_search(){
	local target_dir="$1"
	local keyword="$2"

	for item in "$target_dir"/*; do
		[[ -e "$item" ]] || continue

		if [[ -d "$item" ]]; then
			recursive_search "$item" "$keyword"
		elif [[ -f "$item" ]]; then
			if grep -q "$keyword" "$item" 2>>"$LOG_ERROR"; then
				echo "Found in: $item"
			fi
		fi
	done
}

# --help check
if [[ $1 == "--help" ]]; then
	show_help
	echo "Script name: $0"
	exit 0
fi

#argument count check
if [[ $# -eq 0 ]]; then
	log_error "No arguments provided. Use --help"
	exit 1
fi

echo "All arguments: $@"
echo "Argument count: $#"

#getopts
while getopts ":d:f:k:" args; do
	case $args in
	d) search_dir="$OPTARG" ;;
	k) keyword="$OPTARG" ;;
	f) target_file="$OPTARG" ;;
	:) log_error "Option -$OPTARG requires value"; exit 1 ;;
	*) log_error "Invalid option: -$args"; exit 1;;
	esac
done

#keyword regex validation
if [[ -z "$keyword" || ! "$keyword" =~ ^[A-Za-z0-9_.-]+$ ]]; then
	log_error "Keyword invalid/empty"
	exit 1
fi

#file mode(using HERE String)

if [[ -n "$target_file" ]]; then
	[[ -f "$target_file" ]] || { log_error "File not found"; exit 1; }
	file_content=$(cat "$target_file")

	if grep -q "$keyword" <<< "$file_content"; then
		echo "Keyword '$keyword' found in $target_file"
	else
		echo "Keyword not found"
	fi

# directory mode (RECURSIVE)

elif [[ -n "$search_dir" ]]; then

	[[ -d "$search_dir" ]] || { log_error "Directory not found"; exit 1; }
	
	echo "Recursive search started.."
	recursive_search "$search_dir" "$keyword"
fi

# exit status demo
if [[ $? -eq 0 ]]; then
	echo "Completed Successfully - script: $0"
else
	echo "Execution failed - script: $0"
fi
