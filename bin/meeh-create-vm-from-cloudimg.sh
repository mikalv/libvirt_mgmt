#!/usr/bin/env bash
set -x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ENV_CONFIG=$(realpath $SCRIPT_DIR/../.env)
. $ENV_CONFIG


export NAME=$1
export MEMORY=${3:-"${VM_DEFAULT_MEMORY}"}
export CLOUD_CONFIG_FILE=$2
export ISO_FILE="${VM_DESTDIR}/${NAME}.iso"
export DISK_FILE="${VM_DESTDIR}/${NAME}.qcow2"
export NET_BRIDGE=${4:-"${VM_DEFAULT_NET_BRIDGE}"}
export DISK_SIZE=${5:-"${VM_DEFAULT_DISK_SIZE}"}
export BASE_IMAGE=${CLOUD_IMAGE:-"$VM_DEFAULT_OS_IMAGE"}
export CLOUD_CONFIG_TEMP="${VM_DESTDIR}/${NAME}.isocloud.txt"

if [[ -z "$CLOUD_CONFIG_FILE" ]]; then
  echo "Need at least a VM name..."
  echo "Usage: create-from-cloudimg.sh name cloud-config.txt [memory_in_mb=${MEMORY}] [net_bridge=${NET_BRIDGE}] [disk_in_gb=${DISK_SIZE}]"
  exit 1
fi

# Copy new disk
qemu-img convert -O qcow2 $BASE_IMAGE $DISK_FILE
# Resize
qemu-img resize $DISK_FILE "${DISK_SIZE}G" 2>/dev/null
cp $CLOUD_CONFIG_FILE $CLOUD_CONFIG_TEMP
cloud-localds -f iso9660 -H $NAME $ISO_FILE $CLOUD_CONFIG_TEMP 2>/dev/null
rm -f $CLOUD_CONFIG_TEMP

virt-install \
        --name $NAME \
	--memory $MEMORY \
	--disk $DISK_FILE,format=qcow2,device=disk,bus=virtio \
	--disk $ISO_FILE,device=cdrom \
	--os-type linux \
	--os-variant ubuntu16.04 \
	--virt-type kvm \
  	--graphics none \
	--network=bridge:${NET_BRIDGE} \
	--import \
	--noreboot \
	--noautoconsole

# We'll have to start it manually
virsh --connect qemu:///system start $NAME

echo "[+] Done, waiting 120 seconds for boot log (command: virt-log -d $NAME)"
sleep 120
echo "[+] IPs detected: "
virt-log -d $NAME | grep cloud-init | grep ens2 | awk '{ print $12 }'

