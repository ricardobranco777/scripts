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

size=$(pkg $opts "$cmd" -Fn "$@" | tee /dev/tty | awk '/to be downloaded/ { printf "%s%c", $1 + 10, substr($2, 0, 1) }')
[ -z "$size" ] && exit 0

cleanup() {
	umount -v /mnt/var/cache/pkg
	exit "${1:-1}"
}

trap cleanup HUP QUIT INT

be="default-$(date +'%Y-%m-%d_%H%M%S')"
bectl create "$be"
bectl mount "$be" /mnt

mount -v -t tmpfs -o size="$size" tmpfs /mnt/var/cache/pkg || exit 1

pkg-static -c /mnt $opts "$cmd" "$@"
bectl activate "$be"

cleanup $?
