#!/usr/bin/env bash
CMD=${2:-bash}
nsenter --net=/var/run/netns/$1 $CMD
