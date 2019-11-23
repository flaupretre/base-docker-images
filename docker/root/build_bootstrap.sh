#
# This script is executed by root
# It builds the bootstrap directory, which will then be imported as base for the
# root image.
#============================================================================
set -euo pipefail

[ -z "${FS:-}" ] && exit 1

apt-get update
apt-get -y install \
  debootstrap \
  dirmngr \
  apt-transport-https \
  make \
  curl

mkdir $FS

debootstrap \
  --keyring /etc/apt/trusted.gpg.d/debian-archive-${ROOT_DEBIAN_VERSION}-stable.gpg \
  --force-check-gpg \
  --variant=minbase \
  --components=main,contrib,non-free \
  --include=dirmngr,apt-transport-https \
  --arch=amd64 \
  ${ROOT_DEBIAN_VERSION} \
  $FS \
  http://deb.debian.org/debian/

echo 'APT::Install-Recommends "false";' >$FS/etc/apt/apt.conf.d/00InstallRecommends

echo "deb http://deb.debian.org/debian ${ROOT_DEBIAN_VERSION}-backports main contrib non-free" >>/etc/apt/sources.list.d/backports.list

#-- Install sysfunc

mkdir -p /tmp/sysfunc
cd /tmp/sysfunc
curl https://codeload.github.com/flaupretre/sysfunc/tar.gz/$SYSFUNC_VERSION -o tgz
tar xpf tgz
cd sysfunc-$SYSFUNC_VERSION
INSTALL_ROOT=$FS make install
cd /tmp
rm -r sysfunc
