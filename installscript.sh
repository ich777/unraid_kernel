#!/bin/bash

# Slackware server URL
server_url="http://mirrors.slackware.com/slackware/slackware64-15.0/"

# package names without version number
packages=(
  nano
  curl
  git
  nghttp2
  brotli
  cyrus-sasl
  screen
  bc
  gc
  glibc
  gawk
  kernel-headers
  autoconf-archive
  autoconf
  automake
  binutils
  check
  cmake
  flex
  gcc
  gcc-g++
  guile
  libtool
  m4
  make
  pkg-config
  gettext
  gettext-tools
  strace
  bison
  patch
  squashfs-tools
  kmod
  ncurses
  infozip
  rsync
  libseccomp
  libcap
  util-linux
  perl
  python3
  python-setuptools
  gperf
  eudev
  libpciaccess
  elfutils
  lzo
  lz4
  xxHash
)

# download FILELIST.TXT to get list of packages
wget -O /tmp/FILELIST.TXT "${server_url}/FILELIST.TXT"

# create packages directory
mkdir -p /tmp/packages

# loop through FILELIST.TXT for packages
for package_name in "${packages[@]}"
do
  # find the package in FILELIST.TXT
  package_file=$(grep -E "/${package_name//\+/\\\+}-[0-9]+" /tmp/FILELIST.TXT | awk '{print $8}' | grep -E "txz|tgz" | grep -v ".asc" | grep -v "/source/" | grep -v "/patches/" | sed 's/^\.\///')
  
  # download the package
  if ! wget -P /tmp/packages/ "${server_url}${package_file}" ; then
    echo "ERROR: Download from package: ${package_file##*/} failed!"
    exit 1
  fi
done

# install packages
cd /tmp/packages
installpkg *

cd /tmp

# install jq
jq_v=1.6
wget -O /tmp/jq-${jq_v}-x86_64-1alien.txz https://slackware.uk/people/alien/sbrepos/15.0/x86_64/jq/jq-${jq_v}-x86_64-1alien.txz
installpkg /tmp/jq-${jq_v}-x86_64-1alien.txz

# install xz
xz_v=5.2.5
wget -O /tmp/xz.tar https://github.com/ich777/xz/releases/download/${xz_v}/xz-v${xz_v}.tar.gz
tar -C / -xvf /tmp/xz.tar && \
rm /tmp/xz.tar

# install squashfs-tools
wget -O /tmp/squashfs-tools-4.5-x86_64-2.txz https://slackware.uk/slackware/slackware64-15.0/slackware64/ap/squashfs-tools-4.5-x86_64-2.txz && \
installpkg /tmp/squashfs-tools-4.5-x86_64-2.txz

# install cpio 2.12 because cpio 2.13 is currently broken
wget -O /tmp/cpio-2.12-x86_64-1.txz https://slackware.uk/slackware/slackware64-14.2/slackware64/a/cpio-2.12-x86_64-1.txz
installpkg /tmp/cpio-2.12-x86_64-1.txz

# install lsdiff
wget -O /usr/bin/lsdiff https://github.com/ich777/runtimes/raw/master/lsdiff/lsdiff
chmod +x /usr/bin/lsdiff

# install Perl module: ProcessTable
cpan -i Proc::ProcessTable

# cleanup
rm -rf /tmp/*

# remove README from root directory
if [ -f /README ]; then
  rm -f /README
fi
