#!/bin/sh
#
# Wrapper for NetBSD sysupgrade(8) that:
# - Adds a check command to check if new sets are available
# - Mounts /var/cache/sysupgrade in tmpfs when running auto

set -e

. /usr/pkg/etc/sysupgrade.conf

if [ -z "$RELEASEDIR" ] ; then
	echo "ERROR: Needs RELEASEDIR set" >&2
	exit 1
fi

check() {
	# Get existing sets as a regular expression to be used to filter the hash list
	# Otherwise sha512(1) will print ERROR on missing files
	sets=$(ls /etc/mtree | sed -n 's/^set\.//p' | xargs echo | sed 's/ /|/g')

	tmpfile=$(mktemp)
	ftp -o - "$RELEASEDIR/binary/sets/SHA512" | grep -E "^SHA512 \(($sets)\.t" > "$tmpfile"

	cd /var/cache/sysupgrade
	sha512 -c "$tmpfile"
	status=$?

	rm -f "$tmpfile"

	exit "$status"
}

if [ "$1" = "check" ] ; then
	check
fi

cmd=
opts=

while [ $# -gt 0 ] ; do
	case "$1" in
	-*)
		opts="$opts $1"
		shift ;;
	*)
		cmd="$1"
		shift
		break ;;
	esac
done

case "$cmd" in
	# Note: It makes no sense to run it on fetch as the mounted tmpfs will be gone
	auto)
		RELEASEDIR="${1:-$RELEASEDIR}" ;;
	*)
		exec sysupgrade $opts "$cmd" "$@" ;;
esac

size=$(ftp -o - "$RELEASEDIR/binary/sets/" | grep -Eo '[0-9]+kB' | awk '{ n += $1 } END { print n + 10 }')
[ -z "$size" ] && exit 1

mount_tmpfs -s "${size}k" tmpfs /var/cache/sysupgrade || exit 1

cleanup() {
	umount -v /var/cache/sysupgrade
	exit "${1:-1}"
}

trap cleanup HUP QUIT INT

sysupgrade $opts "$cmd" "$@"
cleanup $?
