#!/bin/sh

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
    echo -e "Please run as root\n"
    exit -1
fi

if [ $# -eq 0 ] ; then
    echo -e "Missing path!" > /dev/stderr
    echo -e "Try '$0 --help' for more information.\n" > /dev/stderr
    exit -2
fi

RED='\033[0;31m'
NC='\033[0m' # No Color

DRIVE_PATH=""
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
            echo -e "Number of passes must be at least 1 (3 is default)!\n" > /dev/stderr
            exit -3
        fi
    fi
done

if [ "$DRIVE_PATH" = "" ] ; then
    echo -e "Missing path!" > /dev/stderr
    echo -e "Try '$0 --help' for more information.\n" > /dev/stderr
    exit -2
fi

echo -e "${RED}This will overwrite all data in 'path'!${NC}"
echo -n "Please confirm [y/n]: "

read opt
if [ "$opt" != "y" ] && [ "$opt" != "Y" ] ; then
    echo -e "OK, bye...\n"
    exit
else
    echo "You asked for it!"
fi

echo "Erasing ${DRIVE_PATH}..."

if [[ $PASSES -eq 1 ]] ; then
    echo -e "${RED}Warning!${NC} The drive will be filled only with zeros and secure erase isn't guaranteed at all!"
    echo -en "Do you want to continue? [y/n]: "
    read opt
    if [ "$opt" != "y" ] && [ "$opt" != "Y" ] ; then
        echo -e "OK, bye...\n"
        exit
    fi
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

