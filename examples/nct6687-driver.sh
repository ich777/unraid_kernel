#!/bin/bash
# Get current uname
UNAME=$(uname -r)

# Create directory for packages if not exists
if [ ! -d ${DATA_DIR}/${UNAME} ]; then
  mkdir -p ${DATA_DIR}/${UNAME}
fi

# Get all CPU threads if CPU_THREADS all is set
if [ "${CPU_THREADS}" == "all" ]; then
  CPU_THREADS=$(nproc --all)
fi

# Create temporary directory in main directory
mkdir ${DATA_DIR}/NCT6687
# Create directory for compiled files
mkdir -p /nct/lib/modules/${UNAME}

# Clone repository
cd ${DATA_DIR}/NCT6687
git clone https://github.com/Fred78290/nct6687d
cd ${DATA_DIR}/NCT6687/nct*

# Get date from last commit since repository has no versions
PLUGIN_VERSION="$(git log -1 --format="%cs" | sed 's/-//g')"

# Apply necessar patch to Makefile
echo -e 'obj-m += nct6687.o

all:
\tmake -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

install: all
\tmake -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules_install

clean:
\tmake -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
' > ${DATA_DIR}/NCT6687/nct*/Makefile

# Compile module and install it to directory for compiled files
make INSTALL_MOD_PATH=/nct install -j${CPU_THREADS}
cd /nct/lib/modules/${UNAME}/

# Remove unnecessary files
rm /nct/lib/modules/${UNAME}/* 2>/dev/null

# Create directory for plugin image and download plugin image
cd ${DATA_DIR}
mkdir -p /nct/usr/local/emhttp/plugins/nct6687-driver/images
wget -O /nct/usr/local/emhttp/plugins/nct6687-driver/images/nuvoton.png https://raw.githubusercontent.com/ich777/docker-templates/master/ich777/images/nuvoton.png

# Create Slackware package
PLUGIN_NAME="nct6687d"
BASE_DIR="/nct"
VERSION="$(date +'%Y.%m.%d')"

mkdir -p $BASE_DIR/install
tee $BASE_DIR/$VERSION/install/slack-desc <<EOF
       |-----handy-ruler------------------------------------------------------|
$PLUGIN_NAME: $PLUGIN_NAME
$PLUGIN_NAME:
$PLUGIN_NAME:
$PLUGIN_NAME: Custom $PLUGIN_NAME package for Unraid Kernel v${UNAME%%-*} by ich777
$PLUGIN_NAME: Source: https://github.com/Fred78290/nct6687d
$PLUGIN_NAME:
$PLUGIN_NAME:
$PLUGIN_NAME:
$PLUGIN_NAME:
$PLUGIN_NAME:
$PLUGIN_NAME:
EOF

cd ${BASE_DIR}
makepkg -l n -c y ${DATA_DIR}/${UNAME}/$PLUGIN_NAME-$PLUGIN_VERSION-$UNAME-1.txz
md5sum ${DATA_DIR}/${UNAME}/$PLUGIN_NAME-$PLUGIN_VERSION-$UNAME-1.txz | awk '{print $1}' > ${DATA_DIR}/${UNAME}/$PLUGIN_NAME-$PLUGIN_VERSION-$UNAME-1.txz.md5

# Cleanup
rm -rf $BASE_DIR ${DATA_DIR}/NCT6687

# For a upload example please look at the upload.sh
