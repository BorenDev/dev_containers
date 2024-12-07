#!/bin/bash

source "env.sh"

podman run -it --rm --name=$1 $CONTAINER_IMAGE_NAME:latest bash
