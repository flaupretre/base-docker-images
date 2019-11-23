#
# Remove useless stuff from directory tree
# Every build script should execute this one before returning
# All the code below must be idempotent
#==========================================================================
set -euo pipefail

[ -z "${FS:+}" ] && FS=''

if [ -d $FS/usr/share/locale ] ; then
  cd $FS/usr/share/locale
  mkdir ../save
  mv en* fr ../save
  rm -rf *
  mv ../save/* .
  rmdir ../save
fi

rm -rf $FS/usr/share/doc

if [ -d $FS/usr/share/man ] ; then
  cd $FS/usr/share/man
  find . -type f | xargs rm
fi

#-- Cleanup apt cache

apt-get clean
find $FS/var/lib/apt/lists/ -maxdepth 2 -type f -delete

