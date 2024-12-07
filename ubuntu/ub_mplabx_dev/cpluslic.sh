#!/bin/bash

# License filename prefix
prefix="xc32fpp"

# Operating system name
os=`uname -s`

# Pick license file location based on OS name
dir=""
if [ `echo $os | awk '{ print $0 ~ "CYGWIN" }'` = "1" ]; then
    if [ `echo $os | awk '{ print $0 ~ "5.2" }'` = "1" ]; then
        dir="$ALLUSERPROFILE/Application Data/Microchip/xclm/license/"
    else
        dir="$ProgramData/Microchip/xclm/license/"
    fi
    slashforward='s/\/\//g'
    dir=`echo $dir | sed -e "$slashforward"`
elif [ `echo $os | awk '{ print $0 ~ "Linux" }'` = "1" ]; then
    dir='/opt/microchip/xclm/license/'
elif [ `echo $os | awk '{ print $0 ~ "Darwin" }'` = "1" ]; then
    dir='/Library/Application Support/Microchip/xclm/license/'
fi

# Announce OS version detected
echo 'Detected operating system: '$os

# Couldn't find a supported operating system ?
if [ -z "$dir" ]; then
    echo 'Operating system '$os' is not supported.'
    exit 1
fi

# Check for existence of license directory
if [ ! -d "$dir" ]; then
    echo 'The folder/directory '$dir' does not exist.'
    echo 'Please install an XC compiler, then rerun the script.'
    exit 1
fi

# Choose license filename
i='1'
while [ `expr $i \< 1000` = "1" ]; do
    file="$dir$prefix-$i.lic"
    if [ ! -f "$file" ]; then
        break
    fi
    i=`expr $i + 1`
done
# Announce license filename
echo
echo "Creating license file $file"

# Write license file
(cat <<_EOF_
This XC32 C++ Free License was created by Microchip Web Activation
Please do not edit the contents of this file
Created on 2/7/2024 05:11:21 PM
_EOF_
) > "$file"
(cat <<_EOF_
LICENSE microchip swxc32-fpp 1.1 permanent uncounted
  hostid=0242ac11ff01 _ck=b5f1fc2059 sig="60P0451JQK0J2J191DGDPQ6FX7PB
  0Q1YVREFXX022HBJFFF1R4BMK4V79Y3JXY8EV52YJHV6Y8"
_EOF_
) >> "$file" 
