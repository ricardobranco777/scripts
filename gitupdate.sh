#!/bin/sh

UPSTREAM="${UPSTREAM:-upstream}"

retry() {
	"$@" || "$@"
}

update() {
	branch=$(git branch --show-current)

	if git remote | grep -qFx "$UPSTREAM" ; then
		retry git pull "$UPSTREAM" "$branch" --rebase
	else
		retry git pull --rebase=true
	fi
}

if [ $# -gt 1 ] ; then
	for dir ; do
		(cd "$dir" && update)
	done
else
	update
fi
