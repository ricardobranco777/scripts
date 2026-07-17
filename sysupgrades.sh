#!/bin/sh
#
# Wrapper around OpenBSD sysupgrade(8) that uses wget2 to download sets faster.
# To avoid writing to disk, they're mounted on mfs.
# Note: This assumes only OpenBSD snapshots, aka -current.
#
# Some snippets adapted from OpenBSD's usr.sbin/sysupgrade/sysupgrade.sh

if ! command -v wget2 >/dev/null 2>&1; then
	echo "ERROR: Install wget2" >&2
	exit 1
fi

tmpdir="$(su -s /bin/sh _syspatch -c 'mktemp -d')"
# 3g in sectors is enough
mount_mfs -s 6291456 swap "$tmpdir" || exit 1

cleanup() {
	cd /
        umount -v "$tmpdir"
	exit "${1:-1}"
}
        
trap cleanup HUP INT QUIT

MIRROR="$(sed 's/#.*//;/^$/d' /etc/installurl)" 2>/dev/null || MIRROR="https://cdn.openbsd.org/pub/OpenBSD"

ARCH="$(uname -m)"
URL="$MIRROR/snapshots/$ARCH"

cd "$tmpdir"
wget2 "$URL/SHA256" "$URL/SHA256.sig"

SETS=$(sed -n -e 's/^SHA256 (\(.*\)) .*/\1/' -e '/^bsd/p;/\.tgz$/p' "$tmpdir/SHA256")

urls=""
for set in $SETS; do
	urls="$urls $URL/$set"
done

wget2 $urls

sysupgrade -n "$@" "$tmpdir"

cleanup $?
