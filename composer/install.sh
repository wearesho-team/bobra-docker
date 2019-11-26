#!/usr/bin/env bash

MODE=${1}
COMPOSER_TOKEN=${2}

case ${MODE} in

  token)
    if [[ ! -z ${COMPOSER_TOKEN} ]]; then
        echo "Empty Composer token argument" > /dev/stderr;
        exit 126;
    fi;
    composer config --global --auth http-basic.repo.packagist.com token ${COMPOSER_TOKEN}
    ;;
  install)
    composer install --prefer-dist --no-scripts --no-dev --no-autoloader --ignore-platform-reqs
    ;;

  dump-autoload)
    composer dump-autoload --no-scripts --no-dev --optimize
    ;;

  *)
    echo "Invalid Mode" > /dev/stderr;
    exit 127;
    ;;
esac
