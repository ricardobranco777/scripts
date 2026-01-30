#!/bin/sh
#
# Wrapper for NetBSD sysupgrade(8) that:
# - Adds a check command to check if new sets are available
# - Mounts /var/cache/sysupgrade in tmpfs when running auto

set -e

. /usr/pkg/etc/sysupgrade.conf
ARCHIVE_EXTENSION="${ARCHIVE_EXTENSION:-tar.xz}"

if [ -z "$RELEASEDIR" ] ; then
	echo "ERROR: Needs RELEASEDIR set" >&2
	exit 1
fi

get_sets() {
	ls /etc/mtree | sed -n 's/^set\.//p'
}

check() {
	# Get existing sets as a regular expression to be used to filter the hash list
	# Otherwise sha512(1) will print ERROR on missing files
	sets=$(get_sets | xargs echo | sed 's/ /|/g')

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

if [ "$cmd" = "auto" ] ; then
	# Note: It makes no sense to run it on fetch as the mounted tmpfs will be gone
	RELEASEDIR="${1:-$RELEASEDIR}"
else
	exec sysupgrade $opts "$cmd" "$@"
fi

size=$(ftp -o - "$RELEASEDIR/binary/sets/" | grep -Eo '[0-9]+kB' | awk '{ n += $1 } END { print n + 10 }')
[ -z "$size" ] && exit 1

mount_tmpfs -s "${size}k" tmpfs /var/cache/sysupgrade || exit 1

if [ "$cmd" = "auto" ] ; then
	# Use wget2 if available to fetch these sets faster
	if command -v wget2 >/dev/null 2>&1; then
		urls=""
		for set in $(get_sets) ; do
			urls="$urls $RELEASEDIR/binary/sets/$set.$ARCHIVE_EXTENSION"
		done
		sysupgrade clean
		(cd /var/cache/sysupgrade && wget2 $urls)
	fi
fi

cleanup() {
	umount -v /var/cache/sysupgrade
	exit "${1:-1}"
}

trap cleanup HUP QUIT INT

sysupgrade $opts "$cmd" "$@"
cleanup $?
