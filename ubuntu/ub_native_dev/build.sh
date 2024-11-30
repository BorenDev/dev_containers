#!/bin/bash

source "env.sh"

$CONTAINER_TOOL build \
    --build-arg USER_NAME=$USER_NAME \
    --build-arg USER_ID=$USER_ID \
    --build-arg GROUP_ID=$GROUP_ID \
    . \
    -t "${CONTAINER_IMAGE_NAME}:$MAJ_MIN_VER" \
    -t "${CONTAINER_IMAGE_NAME}:$MAJOR_VER" \
    -t "${CONTAINER_IMAGE_NAME}:latest" \
    -t "${REMOTE_REGISTRY}${FOLDER}${CONTAINER_IMAGE_NAME}:$MAJ_MIN_VER" \
    -t "${REMOTE_REGISTRY}${FOLDER}${CONTAINER_IMAGE_NAME}:$MAJOR_VER" \
    -t "${REMOTE_REGISTRY}${FOLDER}${CONTAINER_IMAGE_NAME}:latest"
