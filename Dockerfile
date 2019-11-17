FROM tiredofit/nginx-php-fpm:7.3
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca)"

### Set Defaults
ENV FREESCOUT_VERSION=1.3.11 \
    PHP_ENABLE_FILEINFO=TRUE \
    PHP_ENABLE_ICONV=TRUE \
    PHP_ENABLE_IMAP=TRUE \
    PHP_ENABLE_OPENSSL=TRUE \
    PHP_ENABLE_SIMPLEXML=TRUE \
    ZABBIX_HOSTNAME=freescout-app

### Perform Installation
RUN set -x && \
    apk update && \
    apk upgrade && \
    \
    apk add -t .freescout-build-deps \
              build-base \
    && \
    \
    apk add -t .freescout-run-deps \
              expect \
              git \
              gnu-libiconv \
	      && \
    \
### WWW  Installation
    mkdir -p /www/logs && \
    mkdir -p /www/html && \
    mkdir -p /assets/install && \
    curl -sSL https://github.com/freescout-helpdesk/freescout/archive/${FREESCOUT_VERSION}.tar.gz | tar xvfz - --strip 1 -C /assets/install && \
    cd /assets/install && \
    rm -rf \
        .env.example \
        .env.travis \
        .gitattributes \
        .gitcommit \
        .gitignore \
        && \
    \
    chown -R nginx:www-data /assets/install && \
    \
### Update CA Certs
    update-ca-certificates && \
    \
### Cleanup
    apk del .freescout-build-deps && \
    rm -rf /usr/src/* /var/tmp/* /var/cache/apk/*

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php7

### Assets
ADD install /
