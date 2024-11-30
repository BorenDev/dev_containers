#!/bin/bash

source "env.sh"

podman run -it --rm --name=shell $CONTAINER_IMAGE_NAME:latest bash
