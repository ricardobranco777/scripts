#!/bin/sh

BROWSER="${BROWSER:-lynx}"

if [ $# -lt 2 ] || [ $# -gt 3 ] ; then
	echo >&2 "Usage: $0 OS PAGE [SECTION]"
	exit 1
fi

OS="$1"
PAGE="$2"
SECTION="$3"

case "$OS" in
	F|FreeBSD)
		SECTION="${SECTION:-0}"
		URL="https://man.freebsd.org/cgi/man.cgi?query=$PAGE&sektion=$SECTION"
		;;
	N|NetBSD)
		if [ -n "$SECTION" ] ; then
			SECTION=".$SECTION"
		fi
		URL="https://man.netbsd.org/$PAGE$SECTION"
		;;
	O|OpenBSD)
		if [ -n "$SECTION" ] ; then
			SECTION=".$SECTION"
		fi
		URL="https://man.openbsd.org/$PAGE$SECTION"
		;;
	D|DragonflyBSD)
		SECTION="${SECTION:-ANY}"
		URL="https://leaf.dragonflybsd.org/cgi/web-man?command=$PAGE&section=$SECTION"
		;;
	I|Illumos)
		URL="https://illumos.org/man/$SECTION/$PAGE"
		;;
	L|Linux)
		URL="https://man7.org/linux/man-pages/man$SECTION/gperl.$SECTION.html"
		;;
	*)
		echo >&2 "ERROR: Unknown OS: $OS"
		exit 1
esac

exec "$BROWSER" "$URL"
