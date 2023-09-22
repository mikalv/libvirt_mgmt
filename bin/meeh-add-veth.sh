#!/usr/bin/env bash

addveth() {
	local fname=${FUNCNAME[0]}
	Usage() { echo -e "Usage:\n  $fname vename.x,vename.y [vename2.x,vename2.y ...]"; }

	if [[ "${#}" = 0 ]]; then
		Usage >&2
		return 1
	fi

	for pair; do
		read end0 end1 _ <<<"${pair//,/ }"
		if [[ -n "$end0" && -n "$end1" ]]; then
			ip link add $end0 type veth peer name $end1
		else
			Usage >&2
		fi
	done
}
addveth "$@"
