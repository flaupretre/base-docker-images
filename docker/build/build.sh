#!/usr/bin/env bash
#
# base-build image build script
#
# This script runs as root
#=============================================================================
set -euxo pipefail

apt-get update

apt-get install -y \
  binutils \
  git \
  make \
  autoconf \
  automake \
  autotools-dev \
  build-essential \
  dpkg-dev \
  libtool \
  pkg-config

#-- Cleanup

bash /docker.root/cleanup_image.sh
