#!/bin/bash
# Change root pwd to allow login through SSH
echo "root:${ROOT_PWD}" | chpasswd -e
export ROOT_PWD="secret"

# Enable SSH and generate keys if necessary
if [ "${ENABLE_SSH}" == "true" ]; then
  echo "Enabling SSH server, please wait..."
  if [ ! -d ${DATA_DIR}/.ssh ]; then
    mkdir -p ${DATA_DIR}/.ssh
  fi
  if [ ! -f ${DATA_DIR}/.ssh/ssh_host_rsa_key ]; then
    echo "---No ssh_host_rsa_key found, generating!---"
    ssh-keygen -f ${DATA_DIR}/.ssh/ssh_host_rsa_key -t rsa -b 4096 -N "" >/dev/null 2>&1
  fi
  if [ ! -f ${DATA_DIR}/.ssh/ssh_host_ecdsa_key ]; then
    echo "---No ssh_host_ecdsa_key found, generating!---"
    ssh-keygen -f ${DATA_DIR}/.ssh/ssh_host_ecdsa_key -t ecdsa -b 521 -N "" >/dev/null 2>&1
  fi
  if [ ! -f ${DATA_DIR}/.ssh/ssh_host_ed25519_key ]; then
    echo "---No ssh_host_ed25519_key found, generating!---"
    ssh-keygen -f ${DATA_DIR}/.ssh/ssh_host_ed25519_key -t ed25519 -N "" >/dev/null 2>&1
  fi
  /etc/rc.d/rc.sshd start >/dev/null 2>&1
  export SSH_MESSAGE="or connect through SSH "
fi

# Catch Docker stop
term_handler() {
  kill -SIGTERM $(pidof sleep)
  exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM
/opt/scripts/start-container.sh &
killpid="$!"
while true
do
  wait $killpid
  exit 0;
done
