#!/usr/bin/env bash
#
# This file defines docker-base global variables.
#============================================================================

#-- This is the string we use as tag for every image we produce.
#-- If called by CI on tag, tags starting with 'v' will be published and
#-- must correspond to this string.

export VERSION='v1.0.0'

#----- Configurable variables

#-- UID of the dummy non-root user (named 'duser') we provide

export DUSER_UID=1999

#-- Default GID of the 'duser' user ('nogroup')

export DUSER_GID=65534


#-- Root is built using this image

export ROOT_BASE_IMAGE="debian:buster"

#-- Version created by debootstrap

export ROOT_DEBIAN_VERSION="buster"

#-- Goss version to embed

export GOSS_VER='v0.3.7'

#-- Sysfunc version to embed

export SYSFUNC_VERSION='2.2.9'

#--------------
#-- End of configurable part

#-- Container/image names

export CONTAINER_PREFIX='base-'
export IMAGE_ORGANIZATION='ledgerhq'
export IMAGE_PREFIX="$IMAGE_ORGANIZATION/$CONTAINER_PREFIX"

#-- Build stages

export BUILD_STAGES="root run run-jre build build-sbt"

#-- Run stages

export RUN_STAGES=""

#-- Images to push

export PUSH_STAGES="root run run-jre build build-sbt"

#---
# Compute full image name (including tag) from short spec

function img_name()
{
local stage

stage="$1"
echo "$IMAGE_PREFIX$stage:$VERSION"
}
