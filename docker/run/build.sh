#!/usr/bin/env bash
#
# base-run image build script
#
# This script runs as root
#=============================================================================
set -euxo pipefail

#-- Install utilities we want to be present everywhere

apt-get update

apt-get install -y \
  procps \
  lsof \
  netcat \
  iproute2 \
  iputils-ping \
  libcurl3-gnutls \
  curl \
  jq \
  net-tools \
  python3-distutils \
  pv \
  ssh \
  gnupg2 \
  htop \
  vim \
  rsync \
  tcpdump \
  binutils \
  dnsutils \
  less \
  strace \
  sysstat \
  psmisc \
  git \
  ca-certificates

#-- Update CA certificates

d=/usr/local/share/ca-certificates/cacert.org
[ -d $d ] || mkdir -p $d
cd $d
curl -o root.crt http://www.cacert.org/certs/root.crt
curl -o class3.crt http://www.cacert.org/certs/class3.crt
update-ca-certificates

#-- Install goss

url="https://github.com/aelsabbahy/goss/releases/download/$GOSS_VER/goss-linux-amd64"
curl -L "$url" -o "/usr/bin/goss"
chmod +rx "/usr/bin/goss"

#-- Install pip and awscli

cd /tmp
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
rm get-pip.py

pip3 install awscli --upgrade
aws --version

#-- Install kubectl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
  | tee -a /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubectl

#-- Cleanup

bash /docker.root/cleanup_image.sh
