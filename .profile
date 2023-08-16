# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022
umask 007

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

HISTSIZE=-1
HISTFILESIZE=-1

export GOROOT=/usr/local/go
export GOPATH=$HOME/go

for dir in $GOROOT/bin $HOME/.local/bin $GOPATH/bin $HOME/bin ; do
	if [[ ! $PATH == *$dir:* && -d $dir ]] ; then
   		PATH="$dir:$PATH"
	fi
done

# Fix for idiotic "go get"
export GOPROXY=direct

# Fix for idiotic requests not using system certificates
# NOTE: Use /etc/ssl/ca-bundle.pem in SUSE
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
