#!/usr/bin/env bash

function help
{
    echo
    echo "Rename all files with spaces in name to same names but with undercovers"
    echo
    echo "  ./$(basename $0) <path/to/folder>"
    echo

    exit
}

# Show help if first argv is empty
[ "x" == "x$1" ] && help

folder="$1"

find -name "* *" -print0 | sort -rz | \
while read -d $'\0' f
    do
        mv -v "$f" "$(dirname "$f")/$(basename "${f// /_}")"
done