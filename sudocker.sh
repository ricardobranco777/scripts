#!/bin/bash
#
# Create a session with docker group
# A password for the group must have been set with: sudo gpasswd docker
#
# The list of supplementary group ID's is inherited from parent to child processes.
# We need to create a new shell session by adding this group to that list.
# 
# The sg command runs the newgrp command without changing the current group ID,
# effectively adding the docker group to the list of supplementary group ID's.

The reason not to simply run newgrp docker is to avoid changing the current group ID to docker.
if id -Gn | grep -q '\bdocker\b' ; then
	exit 0
fi

exec /usr/bin/sg docker /usr/bin/newgrp "$(id -gn)"
