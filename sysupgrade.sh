#!/bin/sh
#
# Wrapper for NetBSD sysupgrade(8) that adds a check command
# to check if new sets are available by comparing the SHA512

set -e

if [ "$1" != "check" ] ; then
	exec sysupgrade "$@"
fi

. /usr/pkg/etc/sysupgrade.conf

if [ -z "$RELEASEDIR" ] ; then
	echo "ERROR: Needs RELEASEDIR set" >&2
	exit 1
fi

# Get existing sets as a regular expression to be used to filter the hash list
# Otherwise sha512(1) will print ERROR on missing files
sets=$(ls /etc/mtree | sed -n 's/^set\.//p' | xargs echo | sed 's/ /|/g')

tmpfile=$(mktemp)
ftp -o - "$RELEASEDIR/binary/sets/SHA512" | grep -E "^SHA512 \(($sets)\.t" > "$tmpfile"

cd /var/cache/sysupgrade
sha512 -c "$tmpfile" || rm -f "$tmpfile"

rm -f "$tmpfile"
