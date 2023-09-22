#!/usr/bin/env bash

run() {
	[[ $# -eq 0 ]] && return 0
	[[ "$DEBUG" = yes ]] && echo "[sys]" "$@"
	"$@"
}

addif2netns() {
	local ns=$1
	local if=$2
	local addr=$3

	local fname=${FUNCNAME[0]}
	Usage() { echo -e "Usage:\n  $fname <netns> <ifname> [\$ipaddr|dhcp]"; }
	[[ $# -lt 2 ]] && {
		Usage >&2
		return 1
	}

	xaddr() {
		local addr=$1
		[[ "$addr" =~ .*/[1-9]+$ ]] || addr+=/24
		echo $addr
	}

	run ip link set $if netns $ns
	run ip netns exec $ns ip link set dev $if up

	[[ -n "$addr" ]] && {
		if [[ "$addr" = dhcp* ]]; then
			if grep -q 127.0.0.53 /etc/resolv.conf; then
				run netnsexec $ns networkctl renew $if
			else
				local nshome=/opt/NETNS/$ns
				run cp /etc/resolv.conf /etc/resolv.conf.netns.orig
				run netnsexec $ns dhclient -pf $nshome/dhclient-$if.pid $if
				run cp /etc/resolv.conf.netns.orig /etc/resolv.conf
			fi
		else
			run ip netns exec $ns ip addr add $(xaddr $addr) dev $if
			run ip netns exec $ns ip route add default via ${addr%/*} dev $if
		fi
	}
}
addif2netns "$@"

