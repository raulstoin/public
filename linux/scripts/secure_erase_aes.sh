#!/bin/sh

echo

if [ "$1" = "--help" ] ; then
    echo "$0 [FLAGS]..."
    echo "FLAGS are:"
    echo -e "\t-path /PATH/TO/DRIVE"
    echo -e "\t-pass NR_OF_PASSES"
    echo
    echo "e.g. '$0 -path /dev/sda -pass 3'"
    exit
fi

if [ "$EUID" -ne 0 ] ; then
    echo "Please run as root"
    exit -1
fi

ERR_CODE_ORD=$((ERR_CODE_ORD - 1))
if [ $# -eq 0 ] ; then
    echo "Missing path!" > /dev/stderr
    echo "Try '$0 --help' for more information." > /dev/stderr
    exit -2
fi

RED='\033[0;31m'
NC='\033[0m' # No Color

DRIVE_PATH=$1 # /dev/sd"X"
PASSES=3

for ((index = 1; index < ${#}; index++)) ; do
    opt=${!index}
    if [ $opt = '-path' ] ; then
        index=$((index+1))
        DRIVE_PATH=${!index}
    elif [ $opt = '-pass' ] ; then
        index=$((index+1))
        PASSES=${!index}
        if [[ $PASSES -lt 1 ]] ; then
            echo "Number of passes must be at least 1 (3 is default)!" > /dev/stderr
            exit -3
        fi
    fi
done

echo -e "${RED}This will overwrite all data in 'path'!${NC}"
echo -n "Please confirm [y/n]: "

read opt
if [ "$opt" != "y" ] && [ "$opt" != "Y" ] ; then
    echo "OK, bye..."
else
    echo "You asked for it!"
fi

echo
echo "Erasing ${DRIVE_PATH}..."

if [[ $PASSES -eq 1 ]] ; then
    echo "Warning! Drive will only fill with zeros and secure erase isn't guaranteed at all! Press any key to continue..."
    read -n 1 x
fi

# Random data fill
for((pass = 1; pass < ${PASSES}; pass++)) ; do
    echo "PASS ${pass} - random fill"
    openssl enc -aes-256-ctr -pass pass:"$(dd if=/dev/random bs=128 count=1 2>/dev/null | base64)" -nosalt </dev/zero \
        | dd status=progress bs=4M of=${DRIVE_PATH} oflag=direct conv=fdatasync
done

echo "PASS ${PASSES} - zero fill"
# Zero data fill
dd status=progress bs=4M if=/dev/zero of=${DRIVE_PATH} oflag=direct conv=fdatasync

