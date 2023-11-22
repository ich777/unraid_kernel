FROM vbatts/slackware:current

LABEL maintainer="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/unraid_kernel"

ARG CA_CERT_V=20231117
ARG OPENSSL_V=3.1.4
ARG PERL_V=5.38.0
ARG COREUTILS_V=9.4
ARG DCRON_V=4.5
ARG GLIBC=2.38
ARG SLACK_REL=current

RUN cd /tmp && \
        wget --no-check-certificate http://mirrors.slackware.com/slackware/slackware64-${SLACK_REL}/slackware64/n/ca-certificates-${CA_CERT_V}-noarch-1.txz && \
        wget --no-check-certificate http://mirrors.slackware.com/slackware/slackware64-${SLACK_REL}/slackware64/n/openssl-${OPENSSL_V}-x86_64-1.txz && \
        wget --no-check-certificate http://mirrors.slackware.com/slackware/slackware64-${SLACK_REL}/slackware64/d/perl-${PERL_V}-x86_64-1.txz && \
        wget --no-check-certificate http://mirrors.slackware.com/slackware/slackware64-${SLACK_REL}/slackware64/a/coreutils-${COREUTILS_V}-x86_64-1.txz && \
        wget --no-check-certificate http://mirrors.slackware.com/slackware/slackware64-${SLACK_REL}/slackware64/a/dcron-${DCRON_V}-x86_64-13.txz && \
	wget --no-check-certificate http://mirrors.slackware.com/slackware/slackware64-${SLACK_REL}/slackware64/a/aaa_glibc-solibs-${GLIBC}-x86_64-3.txz && \
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

RUN sed -i '/^password[[:space:]]*requisite/s/^/#/' /etc/pam.d/system-auth && \
	sed -i '/^password[[:space:]]*sufficient/s/ use_authtok//' /etc/pam.d/system-auth

RUN cd /tmp && \
	wget -O /tmp/github-release.bz2 https://github.com/github-release/github-release/releases/download/v0.10.0/linux-amd64-github-release.bz2 && \
 	bzip2 -d github-release.bz2 && \
  	cp /tmp/github-release /usr/bin/github-release && \
   	chmod 755 /usr/bin/github-release && \
    	rm -rf /tmp/*

RUN echo -e "Welcome to the unRAID Kernel container!\n\nPlease visit https://github.com/ich777/unraid_kernel/tree/master/examples for\nexample compilation scripts." > /etc/motd

ENV DATA_DIR="/usr/src"
ENV ENABLE_SSH="true"
ENV ROOT_PWD="secret"
ENV DL_ON_START="true"
ENV EXTRACT="true"
ENV OVERWRITE="false"
ENV CPU_THREADS="all"
ENV CLEANUP="false"
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770

WORKDIR /usr/src

ADD /docker-scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]
