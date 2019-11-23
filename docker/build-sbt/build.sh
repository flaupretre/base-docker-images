#!/usr/bin/env bash
#
# base-build-sbt image build script
#
# This script runs as root
#=============================================================================
set -euxo pipefail

#--

apt-get update

apt-get install -qy \
  apt-transport-https \
  software-properties-common \
  gnupg \
  openjdk-11-jdk

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823

add-apt-repository "deb https://dl.bintray.com/sbt/debian /"
apt-get update
apt-get install -qy \
  sbt

# Start sbt with a dummy command to download latest version
sbt version

#-- Cleanup

bash /docker.root/cleanup_image.sh
