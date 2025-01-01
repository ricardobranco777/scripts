#!/usr/bin/env bash

podman rm -vf $(podman ps -aq --external)
podman system prune -f
