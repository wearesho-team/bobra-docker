# syntax = docker/dockerfile:experimental

FROM php:8.5.12-alpine AS build

ENV PHP_CGI=no
ENV PHP_DEBUG=no
ENV PHP_PEAR=no

RUN set -ex \
    && apk add --no-cache --update \
        libgd libwebp libjpeg libpng freetype \
        zlib-dev zlib \
        gd-dev libwebp-dev libjpeg-turbo-dev libpng-dev freetype-dev \
        libxml2-dev libxml2 \
        openssl-dev openssl \
        postgresql-dev libpq \
        argon2-dev argon2 \
        libedit-dev libedit \
        sqlite-dev sqlite \
        libzip-dev libzip \
        libsodium-dev libsodium \
        oniguruma-dev oniguruma \
        icu-dev icu-libs icu-data-full\
        pcre-dev pcre \
        curl-dev \
        alpine-sdk linux-headers \
    && docker-php-source extract \
    && cd /usr/src/php \
    # The build triplet must follow the target architecture, otherwise the
    # arm64 image is configured as x86_64 and the build fails.
    && export BUILD_TRIPLET="$(apk --print-arch)-linux-musl" \
    && export CFLAGS="$PHP_CFLAGS" \
       		CPPFLAGS="$PHP_CPPFLAGS" \
       		LDFLAGS="$PHP_LDFLAGS" \
    && ./configure \
        --build=${BUILD_TRIPLET} \
        --with-config-file-path=/usr/local/etc/php \
        --with-config-file-scan-dir=/usr/local/etc/php/conf.d \
        --enable-option-checking=fatal \
        --without-pear \
        --with-libdir=/usr/lib \
        --with-pgsql \
        --with-sodium \
        --with-openssl \
        --with-mhash \
        --with-pdo-pgsql \
        --disable-mysqlnd \
        --disable-session \
        --disable-cgi \
        --enable-soap \
        --enable-exif \
        --enable-dom \
        --enable-intl \
        --enable-simplexml \
        --with-jpeg \
        --with-webp \
        --enable-mbstring \
        --with-freetype \
        --with-zip \
        --enable-gd \
        --with-openssl \
        --with-zlib \
        --with-curl \
        --enable-fpm \
    && find /usr/local -type f ! -name 'docker-*' -delete \
    && make -j "$(nproc)" \
    && find -type f -name '*.a' -delete \
    && rm -r /usr/local/etc/php/ \
    && make install \
    && (find /usr/local/bin /usr/local/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true) \
    && make clean \
    && apk add libsodium-dev && mkdir -p /usr/local/etc/php/conf.d/ \
    # OPcache is compiled into PHP itself since 8.5: there is no configure
    # option or shared extension for it any more.
    && docker-php-ext-install sodium \
    && docker-php-source delete \
    && apk del *-dev alpine-sdk curl gd zip linux-headers \
    && rm -r /tmp /var/cache/ && mkdir /tmp /var/cache/ \
    && chown -R www-data /tmp \
    && php -v && php -m

# bobra/php:*-debug: the PHP build above plus Xdebug, so both images share a
# single PHP compile per architecture. It is built with php/debug as context,
# which is where its xdebug.ini, php.ini and php-fpm.conf come from.
FROM build AS debug

RUN set -ex \
    && apk add --no-cache --virtual .xdebug-deps $PHPIZE_DEPS linux-headers \
    && export CFLAGS="$PHP_CFLAGS" \
       		CPPFLAGS="$PHP_CPPFLAGS" \
       		LDFLAGS="$PHP_LDFLAGS" \
    && mkdir /usr/src/xdebug && cd /usr/src/xdebug \
    && wget -O xdebug-3.5.3.tgz https://pecl.php.net/get/xdebug-3.5.3.tgz \
    && echo "f073de91bea046106abf4d6071c963ea71e58571df6ce58948ceca89d121cb2d *xdebug-3.5.3.tgz" | sha256sum -c - \
    && tar -xzf xdebug-3.5.3.tgz \
    && cd xdebug-3.5.3 \
    && phpize \
    && ./configure \
    && make -j "$(nproc)" \
    && cp modules/xdebug.so "$(php-config --extension-dir)" \
    && cd / && rm -r /usr/src/xdebug \
    && apk del .xdebug-deps \
    && php -d zend_extension=xdebug -v

COPY xdebug.ini /usr/local/etc/php/conf.d/99-xdebug.ini
COPY php.ini /usr/local/etc/php/
COPY php-fpm.conf /usr/local/etc/php-fpm.conf

WORKDIR /app

# bobra/php. Kept as the last stage so it is what a build without --target
# produces.
FROM build

COPY php.ini /usr/local/etc/php/
COPY php-fpm.conf /usr/local/etc/php-fpm.conf

WORKDIR /app
