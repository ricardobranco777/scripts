#!/bin/sh
#
# Remove .rej & .orig files generated by patch(1)

if [ $# -ne 1 ] ; then
	echo "Usage: $0 DIRECTORY" >&2
	exit 1
fi

if [ "$(uname -s)" != "SunOS" ] ; then
	rm_opts="-vf"
else
	rm_opts="-f"
fi

find . -type f \( -name \*.orig -o -name \*.rej \) -exec rm $rm_opts {} +
