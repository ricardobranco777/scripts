#!/bin/bash

device="/dev/sda1"
directory="/data"
mount_options="ro"

if [[ $# -ne 1 || ! $1 =~ ^on|off$ ]] ; then
	echo "Usage: $0 on|off" >&2
	exit 1
fi

if [ ! -b "$device" ] ; then
	echo "ERROR: $device: Not a block device" >&2
	exit 1
elif [ ! -d "$directory" ] ; then
	echo "ERROR: $directory: Not a directory" >&2
	exit 1
fi

luksUUID=$(sudo cryptsetup luksUUID "$device")
if [[ $luksUUID = "" ]] ; then
	echo "$device: Not LUKS" >&2
	exit 1
fi
volume="luks-$luksUUID"

if [[ $1 = off ]] ; then
	if [[ "/dev/mapper/$volume" != "$(findmnt -no SOURCE "$directory")" ]] ; then
		echo "ERROR: $device not mounted at $directory" >&2
		exit 1
	fi
	for service in nfs-server smbd ; do
		service="$service.service"
		if systemctl --quiet is-enabled "$service" ; then
			sudo systemctl stop "$service"
		fi
	done
	sudo umount -v "$directory"
	sudo cryptsetup -v close "$volume"
else 
	set -e
	sudo cryptsetup -v open "$device" "$volume"
	sudo mount -v -o $mount_options "/dev/mapper/$volume" "$directory" || \
		sudo cryptsetup -v close "$device" "$volume"
	for service in nfs-server smbd ; do
		service="$service.service"
		if systemctl --quiet is-enabled "$service" ; then
			sudo systemctl restart "$service"
		fi
	done
fi
