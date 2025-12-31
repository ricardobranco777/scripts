#!/bin/sh
#
# Wrapper around FreeBSD pkg-upgrade(8) to create a ZFS Boot Environment
# and mount /var/cache/pkg in tmpfs before pkg upgrade

size=$(pkg upgrade -Fn | awk '/to be downloaded/ { printf "%s%c", $1 + 10, substr($2, 0, 1) }')

if [ -z "$size" ] ; then
	exit 0
fi

mount -v -t tmpfs -o size="$size" tmpfs /var/cache/pkg || exit 1

cleanup () {
	umount -v /var/cache/pkg
}

trap cleanup HUP QUIT INT

rootfs=$(mount -p | awk '$2 == "/" { print $3 }')

if [ "$rootfs" = "zfs" ] ; then
	bectl create -r default@"$(date +'%Y-%m-%d_%H%M%S')"
fi

pkg upgrade "$@"

cleanup
