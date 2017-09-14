#!/usr/bin/env bash

root=`pwd`
cd "$root"

function help
{
    echo
    echo "To start the analysis, you must specify the path to the directory with the files"
    echo
    echo "  ./$(basename $0) [-D|-c] <path/to/folder> [<extension>]"
    echo
    echo "  -D          - Enable debug output"
    echo "  -c          - Output in the CSV format"
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
CSV="0"

# Change variables if debug is enabled
### this code is compatible with all versions of BASH above 2
if [ "$1" == "-D" ] || [ "$1" == "-c" ]
    then
        # Show help if second argv is empty
        [ "x" == "x$2" ] && help

        folder="$2"
        extension="*"
        [ "x" != "x$3" ] && extension="*.$3"
        DEBUG="1"
fi

[ "$1" == "-c" ] && DEBUG="0" && CSV="1"

# Search for all files
files=`find "$folder" -type f -iname "$extension" | sed -r 's/\ /\\\ /g'`

# Read all classes from all files
[ "$DEBUG" == "1" ] && echo "$files" | while read line;
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

# MapArray prefix
prefix=$(basename -- $0)
# New tmp folder
mapdir=$(mktemp -d)
# Remove temp folder after we done
trap 'rm -r ${mapdir}' EXIT

put() {
    [ "$#" != 3 ] && exit 1
    mapname=$1; key=$2; value=$3
    [ -d "${mapdir}/${mapname}" ] || mkdir "${mapdir}/${mapname}"
    echo $value >"${mapdir}/${mapname}/${key}"
}

append() {
    [ "$#" != 3 ] && exit 1
    mapname=$1; key=$2; value=$3
    [ -d "${mapdir}/${mapname}" ] || mkdir "${mapdir}/${mapname}"
    echo $value >>"${mapdir}/${mapname}/${key}"
}

get() {
    [ "$#" != 2 ] && exit 1
    mapname=$1; key=$2
    cat "${mapdir}/${mapname}/${key}"
}

# If count of files more zero
if [ "" != "$(echo -n "$files")" ]
    then
        # The title
        [ "$DEBUG" == "1" ] && echo ">>> Masterlist"

        # Search for all files
        grep -Eoi --with-filename class\=\"[^\"]*\" $files | awk -F\: '{print $1"\t"$2}' | sed -r 's/\tclass="(.*)"/\t\1/g' | \
        while read file class
            do
                count=`get "classwork" "CLASSWORK_COUNT_$class" 2>/dev/null`
                put "classwork" "CLASSWORK_COUNT_$class" $(($count+1))

                # Append file path into cell
                append "classwork" "CLASSWORK_FILES_$class" `basename $file`
        done

        # Search for all files
        grep -Eoih class\=\"[^\"]*\" $files | awk -F\" "{print \$2}" | sort | uniq | \
        while read class
            do
                count=`get "classwork" "CLASSWORK_COUNT_$class"`
                files=`get "classwork" "CLASSWORK_FILES_$class" | sort | uniq | tr "\n" " " | sed 's/[[:blank:]]*$//'`
                files_count=`get "classwork" "CLASSWORK_FILES_$class" | sort | uniq | wc -l`

                [ "$CSV" == "1" ] && printf "'%d','%s','%s','%s'\n" "$count" "$class" "$files_count" "$files"
                [ "$CSV" == "0" ] && printf "%7d\t%-20s\t%-4s%s\n" "$count" "$class" "$files_count" "$files"
        done

        # New line
        [ "$DEBUG" == "1" ] && echo
fi
