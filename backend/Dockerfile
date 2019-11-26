FROM ubuntu:18.04
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEN noninteractive

WORKDIR /usr/src/site
EXPOSE 8080
CMD ["/bin/bash", "-c", "/etc/init.d/php7.3-fpm start && nginx"]

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    apt-get install -y software-properties-common locales apt-utils && \
    add-apt-repository ppa:ondrej/php && \
    apt-get install -y nginx \
    php7.3-zip php7.3-bcmath php7.3-soap php7.3-intl php7.3-dom \
    php7.3-simplexml php7.3-fpm php7.3-curl php7.3-gd php7.3 \
    php7.3-mbstring php7.3-pgsql php7.3-pdo php7.3-imagick php7.3-cli

COPY nginx.conf /etc/nginx/
COPY www.conf /etc/php/7.3/fpm/pool.d/
COPY php.ini /etc/php/7.3/fpm/

RUN cp /etc/php/7.3/fpm/php.ini /etc/php/7.3/cli/php.ini && \
    echo "disable_functions = " >> /etc/php/7.3/cli/php.ini

EXPOSE 8080
CMD ["/bin/bash", "-c", "/etc/init.d/php7.3-fpm start && nginx"]
