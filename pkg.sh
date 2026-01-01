#!/bin/sh
#
# Wrapper around FreeBSD pkg(8) to create a ZFS Boot Environment
# and mount /var/cache/pkg in tmpfs before pkg install|upgrade

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
		exec pkg $opts "$cmd" "$@" ;;
esac

size=$(pkg $opts "$cmd" -Fn "$@" | awk '/to be downloaded/ { printf "%s%c", $1 + 10, substr($2, 0, 1) }')
[ -z "$size" ] && exit 0

mount -v -t tmpfs -o size="$size" tmpfs /var/cache/pkg || exit 1

cleanup () {
	umount -v /var/cache/pkg
}

trap cleanup HUP QUIT INT

rootfs=$(mount -p | awk '$2 == "/" { print $3 }')

if [ "$rootfs" = "zfs" ] ; then
	bectl create -r default@"$(date +'%Y-%m-%d_%H%M%S')"
fi

pkg $opts "$cmd" "$@"
status=$?

cleanup

exit $status
