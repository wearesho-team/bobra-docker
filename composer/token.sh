#!/usr/bin/env bash

COMPOSER_TOKEN=${1}

if [[ ! -z ${COMPOSER_TOKEN} ]]; then
    echo "Empty Composer token argument" > /dev/stderr;
    exit 126;
fi;
composer config --global --auth http-basic.repo.packagist.com token ${COMPOSER_TOKEN};
