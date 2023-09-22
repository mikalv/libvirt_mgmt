#!/usr/bin/env bash
modprobe nbd max_part=16
qemu-nbd -c /dev/nbd0 $1
partprobe /dev/nbd0
fdisk -l /dev/nbd0
