#!/bin/bash
if [ "${ENABLE_SSH}" == "true" ]; then
  if [ ! -d ${DATA_DIR}/.ssh ]; then
    mkdir -p ${DATA_DIR}/.ssh
  fi
  /etc/rc.d/rc.sshd start >/dev/null 2>&1
  SSH_MESSAGE="or connect through SSH "
fi

if [ "${CLEANUP}" == "true" ]; then
  echo "Cleaning up, please wait...
  find . -maxdepth 1 -type d -not -name '.ssh' -print0 | xargs -0 -I {} rm -R {} 2&>/dev/null
  echo "Cleanup done, please disable CLEANUP and restart the container."
  sleep infinity
fi

if [ "$DL_ON_START" == "true" ]; then
  UNAME=$(uname -r)
  KERNELS_AVAIL=$(wget -qO- https://api.github.com/repos/ich777/unraid_kernel/releases | jq -r '.[].tag_name')

  if [ "${CPU_THREADS}" == "all" ]; then
    CPU_THREADS=$(nproc --all)
  fi

  if ! echo "${KERNELS_AVAIL}" | grep -q "${UNAME}" ; then
    echo "Kernel version ${UNAME%%-*} not found, putting contianer into sleep mode!"
    sleep infinity
  fi

  echo "Looking for file linux-${UNAME}.tar.xz"
  if [ ! -f ${DATA_DIR}/linux-${UNAME}.tar.xz ]; then
    echo "linux-${UNAME}.tar.xz not found, please wait downloading..."
    if wget -q --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/linux-${UNAME}.tar.xz "https://github.com/ich777/unraid_kernel/releases/download/${UNAME}/linux-${UNAME}.tar.xz" ; then
    echo "Download successful"
  else
    rm -rf ${DATA_DIR}/linux-${UNAME}.tar.xz
    echo "Download failed, putting container into sleep mode."
    sleep infinity
  fi
  else
    echo "linux-${UNAME}.tar.xz found!"
  fi

  if [ "${EXTRACT}" == "true" ]; then
    echo "Extracting archive, please wait..."
    if [ -d ${DATA_DIR}/linux-${UNAME} ]; then
      echo "Directory linux-${UNAME} found, halting container until folder is removed!"
      while [ -d ${DATA_DIR}/linux-${UNAME} ]; do
        echo "Folder still exists, please remove ${DATA_DIR}/linux-${UNAME}"
        sleep 5
      done
      echo "Folder removed, continuing..."
	fi
  else
    mkdir -p ${DATA_DIR}/linux-${UNAME}
    tar -xf ${DATA_DIR}/linux-$UNAME.tar.xz -C ${DATA_DIR}/linux-$UNAME
  fi

  GCC_V=$(gcc -v 2>&1 | grep -oP "(?<=gcc version )[^ ]+")
  PRECOMP_GCC_V=$(grep "CONFIG_CC_VERSION_TEXT" ${DATA_DIR}/linux-${UNAME}/.config | grep -oP '\d+\.\d+(\.\d+)?')
  if [ "${PRECOMP_GCC_V}" != "${GCC_V}" ]; then
    echo "WARNING: gcc version from precompiled Kernel version (v${PRECOMP_GCC_V}) does not match the gcc version from the container (v${GCC_V})."
  fi

  cd ${DATA_DIR}/linux-${UNAME}
  echo "Preparing container, Stage 1 of 2, please wait..."
  make -j${CPU_THREADS} >/dev/null 2>&1
  echo "Stage 1 done, Stage 2 started, please wait..." 
  make modules_install -j${CPU_THREADS} >/dev/null 2>&1
  echo "Stage 2 done"
  echo "The pre-compiled Kernel is located in ${DATA_DIR}/linux-${UNAME}"
  fi
fi

echo "Container ready, please open the console ${SSH_MESSAGE}to the container and go to ${DATA_DIR}"

term_handler() {
  kill -SIGTERM $(pidof sleep)
  exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM
sleep infinity &
killpid="$!"
while true
do
  wait $killpid
  exit 0;
done
