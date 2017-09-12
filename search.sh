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
        # Extract file name from line
        filename=`basename "$line"`

        # Show the file name
        echo ">>> $filename"

        # The filter
        grep -Eoih class\=\"[^\"]*\" "$line" | awk -F\" "{print \$2}" | sort | uniq --count

        # New line
        echo
done
