#!/bin/sh
#
# Use this script to install other OS manpages on your system
#
# Run as non-root and run man(1) with `-m $system`
#
# You may optionally run a deduplicator utility and gzip(1)

set -eu

LOCAL="$HOME/.local/share/man/"

# Aliases in https://man.freebsd.org/cgi/man.cgi/help.html
#SYSTEMS="dragonfly freebsd hpux irix linux macos netbsd openbsd osf1 solaris sunos true64 ultrix v7"
SYSTEMS="freebsd netbsd openbsd dragonfly solaris"

mkdir -p "$LOCAL"
cd "$LOCAL"

for system in $SYSTEMS ; do
	if [ -d "$system" ] ; then
		echo "Skipping $system"
		continue
	else
		mkdir "$system"
	fi
	url="https://man.freebsd.org/cgi/man.cgi?manpath=$system&apropos=2"
	strip=1
	case "$system" in freebsd*) strip=2 ;; esac
	echo "Downloading $system"
	curl -s "$url" | tar -zxf- -C "$system" --strip-components "$strip"
	find "$system" -type d -exec chmod u+w {} +
	find "$system" -mindepth 1 -maxdepth 1 -type d ! -name man\* -exec rm -rf {} +
done
