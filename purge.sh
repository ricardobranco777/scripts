#!/bin/bash
#
# Purge packages in Debian/Ubuntu

dpkg -l | awk '$1 == "rc" { print $2 }' | xargs -r sudo apt purge -y
