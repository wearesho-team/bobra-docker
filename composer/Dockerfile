FROM composer:1.9

RUN composer global require --no-plugins --no-scripts  --prefer-dist hirak/prestissimo

COPY composer-dump-autoload composer-install /usr/local/bin/
