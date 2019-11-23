#!/usr/bin/env bash
#
# root image build script
#
# This script runs as root
#=============================================================================
set -euxo pipefail

set +x
. sysfunc
set -x

#-- Remove non-essential packages

apt-get remove -y --allow-remove-essential \
  e2fsprogs \
  e2fslibs \
  nano \
  pinentry-curses \
  whiptail \
  kmod \
  iptables \
  iproute2 \
  dmidecode

#-- Create 'duser' user

DUSER_HOME=/home/duser

useradd --home $DUSER_HOME -m --gid "$DUSER_GID" --shell /bin/bash --uid "$DUSER_UID" duser

#-- Install utilities we want to be present everywhere

apt-get update

apt-get install -y \
  apt-utils \
  bash-completion \
  vim

#-- Make links

ln -s /docker.$STAGE/dwrap_main.sh /usr/bin/dwrap

#-- Needed for AWS Web identity authentication as AWS gives path to token
#-- as '/var/run/xxx' but, here, it is under '/run'

[ -d /var/run ] || ln -s /run /var/run

#-- Common profile and bashrc

echo "source /docker.root/bash.bashrc" >/etc/bash.bashrc

ln -s /docker.root/bash.profile /etc/profile.d/root

#-- Cleanup

bash /docker.root/cleanup_image.sh
