# ClassWork

A small script for finding and calculating count of CSS classes in files

## How to use

    To start the analysis, you must specify the path to the directory with the files
    
      ./search.sh <path/to/folder> [<extension>]
    
      <extension> - Extension of files for analyze (all files if not set)

## Example of usage

    ```bash
    ./search.sh /some/absolute/path *.html
    ./search.sh some/relative/path *.php
    ```