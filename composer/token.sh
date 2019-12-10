#!/usr/bin/env sh

composer config --global --auth http-basic.repo.packagist.com token ${1}
