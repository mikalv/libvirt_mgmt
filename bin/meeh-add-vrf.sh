#!/usr/bin/env bash

addvrf() {
	local fname=${FUNCNAME[0]}
	local vrfname=$1
	local vrfid=$2
	[[ $# -lt 2 ]] && {
		echo "Usage: $fnname <vrf_name> <vrf_id>" >&2
		return 1
	}

	ip link add dev $vrfname type vrf table $vrfid
	ip link set dev $vrfname up
}
addvrf "$@"
