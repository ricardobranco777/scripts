#!/bin/sh
#
# Wrapper around NetBSD pkg(8) to mount the
# package cache in tmpfs before install & upgrade

cmd=
opts=

while [ $# -gt 0 ] ; do
	case "$1" in
	-*)
		opts="$opts $1"
		shift ;;
	*)
		cmd="$1"
		break ;;
	esac
done

case "$cmd" in
	install|upgrade)
		shift ;;
	*)
		exec pkgin $opts "$cmd" "$@" ;;
esac

size=$(pkgin -dn $opts "$cmd" "$@" | awk '/^[0-9]+[KMG] to download$/ { printf "%s%c", $1 + 10, substr($1, length($1), 1) }')
[ -z "$size" ] && exit 0

mount_tmpfs -s "$size" tmpfs /var/db/pkgin/cache || exit 1

cleanup () {
	umount -v /var/db/pkgin/cache
	exit "${1:-1}"
}

trap cleanup HUP QUIT INT

pkgin $opts "$cmd" "$@"
status=$?

cleanup 0

exit "$status"
