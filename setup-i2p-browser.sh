#! /usr/bin/env sh

validate_i2pbrowser_directory(){
    temp="$1"
    if [ -d "$temp" ]; then
        echo "$temp"
    else
        echo "error; i2pbrowser_directory is not a directory" 1>&2
    fi
}

if [ ! -z "$1" ]; then
    i2pbrowser_directory=$(validate_i2pbrowser_directory "$1")
fi

if [ -z "$i2pbrowser_directory" ]
    echo "error; i2pbrowser_directory unset" 1>&2
    exit 1
fi

