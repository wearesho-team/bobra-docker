FROM php:7.4-alpine

RUN find /usr/local -type f ! -name 'docker-*' -delete \
    && set -ex \
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
        curl-dev \
        alpine-sdk linux-headers \
    && docker-php-source extract

RUN cd /usr/src/php \
    && export CC=clang CFLAGS="-O3 -march=native" PHP_CGI=no PHP_DEBUG=no PHP_PEAR=no \
    && ./configure $(php-config --configure-options) \
        --without-pear \
        --disable-cgi \
        --without-ftp \
        --without-mysqlnd \
        --without-phpdbg \
        --with-libdir=/usr/lib \
        --with-pgsql \
        --with-pdo-pgsql \
        --disable-sqlite \
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
        --with-freetype \
        --with-zip \
        --enable-gd \
    && make clean \
    && make -j "$(nproc)" \
    && find -type f -name '*.a' -delete \
    && make install \
    && (find /usr/local/bin /usr/local/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true) \
    && make clean \
    && apk del *-dev alpine-sdk curl gd zip linux-headers \
    && docker-php-source delete \
    && php -v && php -m

COPY php.ini /usr/local/etc/php/php.ini
WORKDIR /var/www


#FROM bobra/php:7.4
#
#RUN echo "disable_functions = " >> /etc/php/7.4/cli/php.ini
#
#EXPOSE 3000
#CMD ["php-fpm"]
