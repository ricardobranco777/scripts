#!/bin/bash

if [ $# -ne 1 ] ; then
	echo "Usage: $0 DIRECTORY" >&2
	exit 1
fi

SAVEDIR="$1"
[[ $SAVEDIR =~ /$ ]] || SAVEDIR="${SAVEDIR}/"

INCLUDE=(/etc /root /home)
EXCLUDE=(Music Downloads .cache .local/share/Trash .local/share/containers .config/{Microsoft,Slack,BraveSoftware,google-chrome,chromium})

# archive mode is -rlptgoD (no -A,-X,-U,-N,-H)
rsync_options=(--archive --verbose --one-file-system --acls --xattrs --delete)

for exclude in "${EXCLUDE[@]}" ; do
	rsync_options+=(--exclude="$exclude")
done

echo sudo rsync "${rsync_options[@]}" "${INCLUDE[@]}" "$SAVEDIR"
exec sudo rsync "${rsync_options[@]}" "${INCLUDE[@]}" "$SAVEDIR"
