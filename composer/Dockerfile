FROM php:7.3-alpine AS install
ENV COMPOSER_ALLOW_SUPERUSER=1
WORKDIR /usr/src/app
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && \
             composer global require --no-plugins --no-scripts  --prefer-dist hirak/prestissimo
COPY ./dump-autoload.sh ./install.sh ./token.sh /usr/src/app/
