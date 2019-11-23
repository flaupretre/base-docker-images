#!/usr/bin/env bash
#
# base-run-jre image build script
#
# This script runs as root
#=============================================================================
set -euxo pipefail

#--

apt-get update

apt-get install -y \
  openjdk-11-jre

#-- Cleanup

bash /docker.root/cleanup_image.sh
