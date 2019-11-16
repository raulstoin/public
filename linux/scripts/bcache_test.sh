#!/bin/bash

BACK_DEVICE="/home/linux/to_cache"
CACHE_DEVICE="/home/linux/the_cache"

BACK_BLOCK="loop10"
CACHE_BLOCK="loop11"
BCACHE_BLOCK="bcache0"

BACK_DEV="/dev/$BACK_BLOCK"
CACHE_DEV="/dev/$CACHE_BLOCK"
BCACHE_DEV="/dev/$BCACHE_BLOCK"

MOUNTPOINT="/mnt/bcache_mountpoints"

REAL_DIR_TO_CACHE="/mnt/other_point"

function start {
#     preInit
    create
    format
    mountCache
}

function startService {
    start
    while true ; do
        sleep 365d
    done
}

function preInit {
    rm -f "$BACK_DEVICE" "$CACHE_DEVICE"
    fallocate -l 10G "$BACK_DEVICE"
    fallocate -l 512M "$CACHE_DEVICE"
}

function create {
#     sudo losetup -d "$BACK_DEV"
#     sudo losetup -d "$CACHE_DEV"

    sudo losetup "$BACK_DEV" "$BACK_DEVICE"
    sudo losetup "$CACHE_DEV" "$CACHE_DEVICE"
#     sudo make-bcache -B "$BACK_DEV" -C "$CACHE_DEV"

    ### Get cache UUID ###
    CACHE_UUID=$(sudo bcache-super-show "$CACHE_DEV" | grep cset.uuid | cut -f3)
    sync
    ### Attach cache ###
    echo $CACHE_UUID | sudo tee "/sys/block/$BCACHE_BLOCK/bcache/attach" > /dev/null
    sync
    ### Change cache mode ###
    echo writeback | sudo tee "/sys/block/$BCACHE_BLOCK/bcache/cache_mode" > /dev/null
    sync
}

function format {
    ### Format and mount cache block ###
    echo "Formating $BCACHE_DEV..."
#     sudo mkfs -t ext4 "$BCACHE_DEV"
}

function mountCache {
    sudo mkdir -p "$MOUNTPOINT"
    sudo chmod 0711 "$MOUNTPOINT"
    sudo mount "$BCACHE_DEV" "$MOUNTPOINT"
    sync
#     sudo chown -R $USER "$MOUNTPOINT"

    MOUNTPOINT_NAME="bla"
    sudo mkdir "$MOUNTPOINT/$MOUNTPOINT_NAME"
    sudo mount --bind "$REAL_DIR_TO_CACHE" "$MOUNTPOINT/$MOUNTPOINT_NAME"
    sudo ln -s "$MOUNTPOINT/$MOUNTPOINT_NAME" "/mnt/$MOUNTPOINT_NAME"
    sync
}

function stop {
    sync

    ### Unmount all mounted caches ###
    OIFS="$IFS"
    IFS=$'\n' # For ls to work with spaces
    for fileOrDir in $(sudo ls "$MOUNTPOINT") ; do
        echo "Unmounting $MOUNTPOINT/$fileOrDir..."
        sudo umount "$MOUNTPOINT/$fileOrDir" || exit -2
        sync
        sudo rm "/mnt/$fileOrDir"
    done
    IFS="$OIFS"

    ### Query for UUID of the cache ###
    CACHE_UUID=$(sudo bcache-super-show "$CACHE_DEV" | grep cset.uuid | cut -f3)

    ### Remove mount point ###
    sudo umount "$MOUNTPOINT" || exit -2
    sync
    sudo rm -rf "$MOUNTPOINT"

    ### Stop, detach and remove cache ###
    echo 1 | sudo tee "/sys/block/$BACK_BLOCK/bcache/stop" > /dev/null
#     echo 1 | sudo tee "/sys/block/$CACHE_BLOCK/bcache/detach" > /dev/null
#     echo $CACHE_UUID | sudo tee /sys/block/bcache0/bcache/detach
    echo 1 | sudo tee /sys/fs/bcache/$CACHE_UUID/stop > /dev/null
    sudo losetup -d "$BACK_DEV"
    sudo losetup -d "$CACHE_DEV"
    sync
}

$1