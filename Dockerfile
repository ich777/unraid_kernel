FROM vbatts/slackware:15.0

LABEL maintainer="admin@minenet.at"

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

ENV DATA_DIR="/usr/src"
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="build"

RUN mkdir -p $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
ADD /deps/ /tmp/deps/
RUN chmod -R 770 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]
