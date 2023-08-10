#!/bin/bash
#
# Create a session with docker group
# A password for the group must have been set with: sudo gpasswd docker

if id -Gn | grep -q '\bdocker\b' ; then
	exit 0
fi

exec /usr/bin/sg docker /usr/bin/newgrp "$(id -gn)"
