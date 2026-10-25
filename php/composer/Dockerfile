# Pinned by digest: composer:2.10.3 is rebuilt whenever a new PHP release comes
# out, and bobra/php-composer is tagged with the PHP version inside it (./sync
# reads it from the registry). The digest makes both reproducible, and Renovate
# opens a PR when the upstream image is rebuilt.
FROM composer:2.10.3@sha256:b6dcd72ca98fa19d0e5b8476de179859704891fad06dd9e0b96833d4c430a5fc AS vendor

ENV COMPOSER_HOME=/usr/local/var/composer/
ENV COMPOSER_HTACCESS_PROTECT=0

WORKDIR /usr/src/app/

