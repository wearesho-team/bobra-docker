FROM bobra/composer:7.4 AS composer

ARG COMPOSER_TOKEN
RUN ./token.sh ${COMPOSER_TOKEN}

COPY composer.json composer.lock /usr/src/app/
RUN ./install.sh

COPY ./src/ /usr/src/app/src/
RUN ./dump-autoload.sh

FROM bobra/backend:7.4
COPY --from=composer /usr/src/app/vendor/ /usr/src/site/vendor/
COPY . .
