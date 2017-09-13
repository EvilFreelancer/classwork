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

if [ "x" == "x$1" ]; then help; else folder="$1"; fi
if [ "x" != "x$2" ]; then extension="*.$2"; else extension="*"; fi

find "$folder" -type f -name "$extension" | while read line;
    do
        # If files is found
        found=true

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
count=`ls -1 "$folder"/$extension 2>/dev/null | wc -l`
if [ $count != 0 ]; then
    # The title
    echo ">>> Masterlist"

    # Search for all files
    grep -Eoih class\=\"[^\"]*\" "$folder"/$extension | awk -F\" "{print \$2}" | sort | uniq --count | \
    while read count class
        do
            # Matched files
            files_match=`grep class\=\"[$class]*\" --files-with-matches "$folder"/$extension`

            # Names of matched files
            files=`basename -a $files_match | tr "\n" " "`

            # Count of matched files
            files_count=`echo "$files_match" | wc -l`

            # Print formatted string
            printf "%7d\t%-20s\t%-4s%s\n" "$count" "$class" "$files_count" "$files"
    done

    # New line
    echo
fi
