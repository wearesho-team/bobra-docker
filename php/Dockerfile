# syntax = docker/dockerfile:experimental

FROM php:7.4.12-alpine

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
        icu-dev icu-libs\
        pcre-dev pcre \
        curl-dev \
        alpine-sdk linux-headers \
    && docker-php-source extract \
    && cd /usr/src/php \
    && export CFLAGS="$PHP_CFLAGS" \
       		CPPFLAGS="$PHP_CPPFLAGS" \
       		LDFLAGS="$PHP_LDFLAGS" \
    && ./configure \
        --build=x86_64-linux-musl \
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
        --enable-opcache \
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
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install opcache sodium \
    && docker-php-source delete \
    && apk del *-dev alpine-sdk curl gd zip linux-headers \
    && rm -r /tmp /var/cache/ && mkdir /tmp /var/cache/ \
    && chown -R www-data /tmp \
    && php -v && php -m

COPY php.ini /usr/local/etc/php/
COPY php-fpm.conf /usr/local/etc/php-fpm.conf

WORKDIR /app
