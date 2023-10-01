FROM vbatts/slackware:15.0

LABEL maintainer="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/unraid_kernel"

ARG CA_CERT_V=20211216
ARG OPENSSL_V=1.1.1m
ARG PERL_V=5.34.0
ARG COREUTILS_V=9.0
ARG DCRON_V=4.5

RUN cd /tmp && \
        wget --no-check-certificate http://mirrors.slackware.com/slackware/slackware64-15.0/slackware64/n/ca-certificates-${CA_CERT_V}-noarch-1.txz && \
        wget --no-check-certificate http://mirrors.slackware.com/slackware/slackware64-15.0/slackware64/n/openssl-${OPENSSL_V}-x86_64-1.txz && \
        wget --no-check-certificate http://mirrors.slackware.com/slackware/slackware64-15.0/slackware64/d/perl-${PERL_V}-x86_64-1.txz && \
        wget --no-check-certificate http://mirrors.slackware.com/slackware/slackware64-15.0/slackware64/a/coreutils-${COREUTILS_V}-x86_64-3.txz && \
        wget --no-check-certificate http://mirrors.slackware.com/slackware/slackware64-15.0/slackware64/a/dcron-${DCRON_V}-x86_64-11.txz && \
        installpkg * && \
        /usr/sbin/update-ca-certificates --fresh

COPY installscript.sh /tmp/

RUN chmod +x /tmp/installscript.sh && \
        /tmp/installscript.sh

RUN mkdir -p /run/sshd && \
        sed -i "/#Port 22/c\Port 8022" /etc/ssh/sshd_config && \
        sed -i "/#ListenAddress 0.0.0.0/c\ListenAddress 0.0.0.0" /etc/ssh/sshd_config && \
        sed -i "/#HostKey \/etc\/ssh\/ssh_host_rsa_key/c\HostKey \/usr\/src\/.ssh\/ssh_host_rsa_key" /etc/ssh/sshd_config && \
        sed -i "/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/c\HostKey \/usr\/src\/.ssh\/ssh_host_ecdsa_key" /etc/ssh/sshd_config && \
        sed -i "/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/c\HostKey \/usr\/src\/.ssh\/ssh_host_ed25519_key" /etc/ssh/sshd_config && \
        sed -i "/#PermitRootLogin prohibit-password/c\PermitRootLogin yes" /etc/ssh/sshd_config

RUN cd /tmp && \
	wget -O /tmp/github-release.bz2 https://github.com/github-release/github-release/releases/download/v0.10.0/linux-amd64-github-release.bz2 && \
 	bzip2 -d github-release.bz2 && \
  	cp /tmp/github-release /usr/bin/github-release && \
   	chmod 755 /usr/bin/github-release && \
    	rm -rf /tmp/* /tmp/.*

ENV DATA_DIR="/usr/src"
ENV ENABLE_SSH="true"
ENV DL_ON_START="true"
ENV EXTRACT="true"
ENV CPU_THREADS="all"
ENV CLEANUP="false"
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="build"

WORKDIR /usr/src

RUN mkdir -p $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]
