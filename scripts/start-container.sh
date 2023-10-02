#!/bin/bash
# Execute cleanup and sleep container afterwards
if [ "${CLEANUP}" == "true" ]; then
  echo "Cleaning up, please wait..."
  find . -maxdepth 1 -type d -not -name '.ssh' -print0 | xargs -0 -I {} rm -R {} 2&>/dev/null
  echo "Cleanup done, please disable CLEANUP and restart the container."
  sleep infinity
fi

# Download pre compiled Kernel for current Kernel version
if [ "$DL_ON_START" == "true" ]; then
  UNAME=$(uname -r)
  KERNELS_AVAIL=$(wget -qO- https://api.github.com/repos/ich777/unraid_kernel/releases | jq -r '.[].tag_name')

  # Set CPU threads to use
  if [ "${CPU_THREADS}" == "all" ]; then
    CPU_THREADS=$(nproc --all)
  fi

  # Check if pre compiled Kernel version is availabl, sleep container if not
  if ! echo "${KERNELS_AVAIL}" | grep -q "${UNAME}" ; then
    echo "Kernel version ${UNAME%%-*} not found, putting contianer into sleep mode!"
    sleep infinity
  fi

  # Check if pre compiled archive is locally available
  echo "Looking for file linux-${UNAME}.tar.xz"
  if [ ! -f ${DATA_DIR}/linux-${UNAME}.tar.xz ]; then
    echo "linux-${UNAME}.tar.xz not found, please wait downloading..."
    if wget -q --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/linux-${UNAME}.tar.xz "https://github.com/ich777/unraid_kernel/releases/download/${UNAME}/linux-${UNAME}.tar.xz" ; then
      echo "Download successful, please wait..."
    else
      rm -rf ${DATA_DIR}/linux-${UNAME}.tar.xz
      echo "Download failed, putting container into sleep mode."
      sleep infinity
    fi
  else
    echo "linux-${UNAME}.tar.xz found!"
  fi

  # Extract pre compiled archive
  if [ "${EXTRACT}" == "true" ]; then
    echo "Extracting archive, please wait..."
    # Check if overwrite pre compiled Kernel is enabled
    if [ "${OVERWRITE}" != "true" ]; then
      if [ -d ${DATA_DIR}/linux-${UNAME} ]; then
        echo "Directory linux-${UNAME} found, halting container until folder is removed!"
        while [ -d ${DATA_DIR}/linux-${UNAME} ]; do
          echo "Folder still exists, please remove ${DATA_DIR}/linux-${UNAME}"
          sleep 5
        done
        if [ ! -f ${DATA_DIR}/linux-${UNAME}.tar.xz ]; then
          echo "Something went wrong, file ${DATA_DIR}/linux-${UNAME}.tar.xz isn't in place any more. Please restart the container."
          sleep infinity
        else
          echo "Folder removed, continuing..."
        fi
      fi
    fi
    echo "Extracting, please wait..."
    mkdir -p ${DATA_DIR}/linux-${UNAME}
    tar -xf ${DATA_DIR}/linux-$UNAME.tar.xz -C ${DATA_DIR}/linux-$UNAME
    # Check if gcc version matches, if not display warning
    GCC_V=$(gcc -v 2>&1 | grep -oP "(?<=gcc version )[^ ]+")
    PRECOMP_GCC_V=$(grep "CONFIG_CC_VERSION_TEXT" ${DATA_DIR}/linux-${UNAME}/.config | grep -oP '\d+\.\d+(\.\d+)?')
    if [ "${PRECOMP_GCC_V}" != "${GCC_V}" ]; then
      echo "WARNING: gcc version from precompiled Kernel version v${PRECOMP_GCC_V} does not match the gcc version from the container v${GCC_V}."
    fi
    # Prepare container and install modules
    cd ${DATA_DIR}/linux-${UNAME}
    rm -rf /lib/modules
    rm -rf /lib/firmware
    mkdir -p /lib/modules
    mkdir -p /lib/firmware
    echo "Preparing container, Stage 1 of 2, please wait..."
    make -j${CPU_THREADS} >/dev/null 2>&1
    echo "Stage 1 done! Stage 2 started, please wait..." 
    make modules_install -j${CPU_THREADS} >/dev/null 2>&1
    echo "Stage 2 done"
    echo "The pre-compiled Kernel is located in ${DATA_DIR}/linux-${UNAME}"
  fi
fi

# Display container ready message
echo "Container ready, please open the console ${SSH_MESSAGE}to the container and go to ${DATA_DIR}"
