#!/usr/bin/env bash

function check_command() {
  [[ "$(command -v $1)" ]] || { echo "$2" 1>&2 ; exit 1; }
}

typep() {
   command -p env -i PATH="$PATH" sh -c '
      export LC_ALL=C LANG=C
      cmd="$1"
      cmd="`type "$cmd" 2>/dev/null || { echo "error: command $cmd not found; exiting ..." 1>&2; exit 1; }`"
      [ $? != 0 ] && exit 1
      case "$cmd" in
        *\ /*) exit 0;;
            *) printf "%s\n" "error: $cmd" 1>&2; exit 1;;
      esac
   ' _ "$1" || exit 1
}

typep virsh
typep cloud-localds
typep qemu-img
typep virt-install
typep virt-log
typep guestmount

