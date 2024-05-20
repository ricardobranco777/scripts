#!/bin/sh

UPSTREAM="${UPSTREAM:-upstream}"

update () {
	branch=$(git branch --show-current)

	if git remote | grep -qFx "$UPSTREAM" ; then
		git fetch "$UPSTREAM" && git merge "$UPSTREAM/$branch"
	else
		git pull --rebase=true
	fi
}

if [ $# -gt 1 ] ; then
	for dir ; do
		(cd "$dir" && update)
	done
else
	update
fi
