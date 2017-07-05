#!/bin/sh

if [[ $EUID != 0 ]] ; then
    echo This must be run as root!
    exit 1
fi

# USB 1.1/1.x - ohci,uhci
# USB 2.0 - ehci
# USB 3.1 (rev 0, rev 1) - xhci

for it in /sys/bus/pci/drivers/[uoex]hci_hcd/????:??:??.?; do
    echo "${it##*/}" > "${it%/*}/unbind"
    echo "${it##*/}" > "${it%/*}/bind"
done

