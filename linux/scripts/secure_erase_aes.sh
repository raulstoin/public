#!/bin/sh

RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

if [ "$1" = "--help" ] ; then
    echo "$0 [FLAGS]..."
    echo
    echo "FLAGS are:"
    echo -e "\n     ${BOLD}--path${NORMAL}=PATH_TO_DRIVE"
    echo -e "           Path to drive to erase."
    echo -e "\n     ${BOLD}--pass${NORMAL}=N"
    echo -e "           Number of passes of overwriting. The last pass is always a zero fill, other N-1 are random fills. Minimum value is 1, default value is 3."
    echo -e "\n     ${BOLD}--skip-last-pass${NORMAL}"
    echo -e "           Number of passes of overwriting. The last pass is always a zero fill, other N-1 are random fills. Minimum value is 1, default value is 3."
    echo
    echo "e.g. '$0 --path=/dev/sda --pass=3'"
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

DRIVE_PATH=""
PASSES=3
SKIP_LAST=0

for ((index = 1; index <= ${#}; index++)) ; do
    opt=$(echo ${!index} | cut -d"=" -f 1)
    val=$(echo ${!index} | cut -d"=" -f 2)
    if [ $opt = '--path' ] ; then
        DRIVE_PATH=${val}
    elif [ $opt = '--pass' ] ; then
        PASSES=${val}
        if [[ $PASSES -lt 1 ]] ; then
            echo -e "Number of passes must be at least 1 (3 is default)!\n" > /dev/stderr
            exit -3
        fi
    elif [ $opt = '--skip-last-pass' ] ; then
        SKIP_LAST=1
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

echo "Erasing '${DRIVE_PATH}'..."

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
        | dd status=progress bs=16M of=${DRIVE_PATH} iflag=fullblock oflag=direct conv=fdatasync
done

if [ $SKIP_LAST -eq 0 ] ; then
    echo "PASS ${PASSES} - zero fill"
    # Zero data fill
    dd status=progress bs=16M if=/dev/zero of=${DRIVE_PATH} iflag=fullblock oflag=direct conv=fdatasync
fi

echo -e "\nPath '${DRIVE_PATH}' has been completely overwritten!\n"

