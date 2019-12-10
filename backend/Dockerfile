FROM ubuntu:18.04
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEN noninteractive

WORKDIR /usr/src/site
EXPOSE 8080
CMD ["/bin/bash", "-c", "/etc/init.d/php7.4-fpm start && nginx"]

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    apt-get install -y software-properties-common locales apt-utils && \
    add-apt-repository ppa:ondrej/php && \
    apt-get install -y nginx \
    php7.4-zip php7.4-bcmath php7.4-soap php7.4-intl php7.4-dom \
    php7.4-simplexml php7.4-fpm php7.4-curl php7.4-gd php7.4 \
    php7.4-mbstring php7.4-pgsql php7.4-pdo php7.4-imagick php7.4-cli

COPY nginx.conf /etc/nginx/
COPY www.conf /etc/php/7.4/fpm/pool.d/
COPY php.ini /etc/php/7.4/fpm/

RUN cp /etc/php/7.4/fpm/php.ini /etc/php/7.4/cli/php.ini && \
    echo "disable_functions = " >> /etc/php/7.4/cli/php.ini

EXPOSE 8080
CMD ["/bin/bash", "-c", "/etc/init.d/php7.4-fpm start && nginx"]
