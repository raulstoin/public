#!/bin/bash
dir=$(pwd)
/sys/bus/usb/devices/2-3/power
sudo chown raul:raul usb2_hardware_lpm
echo 0 > usb2_hardware_lpm
cd $dir

