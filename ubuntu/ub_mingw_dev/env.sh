# This environment file contains environment values for shell support scripts.
#
# Example values
# CONTAINER_TOOL=podman
# CONTAINER_IMAGE_NAME=ub_mingw_dev
# REMOTE_REGISTRY="<registry_url>:5000/"
# FOLDER="ub_mingw_dev/"
# MAJOR_VER=0
# MINOR_VER=$MAJOR_VER.1

CONTAINER_TOOL=podman
CONTAINER_IMAGE_NAME=ub_mingw_dev
REMOTE_REGISTRY=""
FOLDER="ubuntu_dev/"
MAJOR_VER=0
MINOR_VER=1
BUILD_VER=1
MAJ_MIN_VER=$MAJOR_VER.$MINOR_VER
D_VERSION=$MAJOR_VER.$MINOR_VER.$BUILD_VER

# User
USER_NAME=developer
USER_ID=1000
GROUP_ID=1000

WORKDIR=/workdir

# Build ARG vars
