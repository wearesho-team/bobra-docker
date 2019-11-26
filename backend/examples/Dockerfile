FROM bobra/composer:7.3 AS composer

ARG COMPOSER_TOKEN
RUN ./token.sh ${COMPOSER_TOKEN}

COPY composer.json composer.lock /usr/src/app/
RUN ./install.sh

COPY ./src/ /usr/src/app/src/
RUN ./dump-autoload.sh

FROM bobra/backend:7.3
COPY --from=composer /usrc/src/app/vendor/ /usr/src/site/vendor/
COPY . .
