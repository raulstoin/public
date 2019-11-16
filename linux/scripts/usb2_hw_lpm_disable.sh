#!/bin/bash

echo 0 | sudo tee /sys/bus/usb/devices/2-3/power/usb2_hardware_lpm
