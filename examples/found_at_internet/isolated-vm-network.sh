#!/bin/bash
ip netns del test
ip link del vm-host1
ip link del br0

set -eu

ip link add br0 type bridge
ip addr add dev br0 10.10.0.1/24
ip link set dev br0 up

ip netns add test

echo creating veth
ip link add vm1-host type veth peer name vm1-netns
ip link set dev vm1-host master br0
ip link set dev vm1-netns netns test
ip link set dev vm1-host up

echo creating tuntap
ip netns exec test ip tuntap add vm1-tap mode tap
ip netns exec test ip addr add 10.10.0.2/24 dev vm1-netns
ip netns exec test ip addr add 10.0.2.2/24 dev vm1-tap
ip netns exec test ip link set dev vm1-netns up
ip netns exec test ip link set dev vm1-tap up
ip netns exec test ip route add default via 10.10.0.1

# Mask QEMU 10.0.2.0/24
ip netns exec test iptables -A POSTROUTING -t nat -o vm1-netns -j MASQUERADE

# For internet access You will also need a masquerade rule on your outgoing interface in the main network namespace
echo sudo ip netns exec test qemu-system-x86_64 -runas qemu -accel kvm -drive file=install66.fs,if=virtio -nic tap,id=tap0,ifname=vm1-tap,script=no,downscript=no -nographic


# Result: each VM gets NATed into an address in 10.10.0.0/24 or whatever network you use. You can also add a redirect in the network namespace:

sudo ip netns exec test iptables -A PREROUTING -t nat -d 10.10.0.2 -j DNAT --to-destination 10.0.2.15
