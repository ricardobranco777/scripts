#!/bin/bash
#
# mount all pseudo filesystems into a chroot and chroot

if [[ $# -ne 2 || ! $1 =~ ^mount|umount$ ]] ; then
	echo "Usage: $0 mount|umount DIRECTORY" >&2
	exit 1
fi

ACTION="$1"
TARGET="$2"

if [ ! -d "$TARGET" ] ; then
	echo "ERROR: Not a directory: $TARGET" >&2
	exit 1
fi

if [[ $ACTION = umount ]] ; then
	for dir in "${dirs[@]}" ; do
		umount -v "$dir"
	done
fi

if [[ $ACTION = mount ]] ; then
	mapfile -t dirs < <(findmnt --pseudo --list -no TARGET | grep -Ev -e '^/$' -e '^/(run|tmp|var)')
else
	mapfile -t dirs < <(findmnt --pseudo --list -no TARGET | grep "^$TARGET" | sort -r)
fi

cleanup() {
	for dir in "${dirs[@]}" ; do
		umount -v "$dir"
	done
}

if [[ $ACTION = mount ]] ; then
	cleanup
	exit
fi

trap cleanup ERR

set -e

for dir in "${dirs[@]}" ; do
	mount -v --mkdir --bind "$dir" "$TARGET/$dir"
done

chroot "$TARGET"
