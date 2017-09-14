#!/usr/bin/env bash

function help
{
    echo
    echo "To start the analysis, you must specify the path to the directory with the files"
    echo
    echo "  ./$(basename $0) <path/to/folder> [<extension>]"
    echo
    echo "  <extension> - Extension of files for analyze (all files if not set)"
    echo

    exit
}

# Show help if first argv is empty
[ "x" == "x$1" ] && help

# Default states
folder="$1"
extension="*"
[ "x" != "x$2" ] && extension="*.$2"
DEBUG="0"

# Change variables if debug is enabled
### this code is compatible with all versions of BASH above 2
if [ "$1" == "-D" ]
    then
        # Show help if second argv is empty
        [ "x" == "x$2" ] && help

        folder="$2"
        extension="*"
        [ "x" != "x$3" ] && extension="*.$3"
        DEBUG="1"
fi

# Search for all files
files=`find "$folder" -type f -name "$extension"`

# Read all classes from all files
[ "$DEBUG" == "1" ] && echo -n "$files" | while read line;
    do
        # Extract file name from line
        filename=`basename "$line"`

        # Show the file name
        echo ">>> $filename"

        # The filter
        grep -Eoih class\=\"[^\"]*\" "$line" | awk -F\" "{print \$2}" | sort | uniq --count

        # New line
        echo
done

# Test if folder is not empty
count=`echo -n "$files" | wc -l`

# If count of files more zero
if [ "$count" != 0 ]
    then
        # The title
        [ "$DEBUG" == "1" ] && echo ">>> Masterlist"

        # Search for all files
        grep -Eoih -R class\=\"[^\"]*\" "$folder" | awk -F\" "{print \$2}" | sort | uniq --count | \
        while read count class
            do
                # Matched files
                files_match=`grep -R class\=\"[$class]*\" --files-with-matches "$folder"`

                # Names of matched files
                files=`basename -a $files_match | tr "\n" " "`

                # Count of matched files
                files_count=`echo "$files_match" | wc -l`

                # Print formatted string
                printf "%7d\t%-20s\t%-4s%s\n" "$count" "$class" "$files_count" "$files"
        done

        # New line
        [ "$DEBUG" == "1" ] && echo
fi
