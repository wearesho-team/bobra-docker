FROM alpine:3.23

LABEL maintainer="Wearesho Team <cto@wearesho.com>"

ENV NGINX_VERSION=1.31.1
ENV HEADERS_MORE_VERSION=0.39

RUN set -x \
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && set -x \
    && tempDir="$(mktemp -d)" \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        libc-dev \
        make \
        pcre-dev \
        zlib-dev \
        linux-headers \
        libedit-dev \
        alpine-sdk \
        findutils \
        git \
        cmake \
    && cd ${tempDir} && wget "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" && tar zxvf nginx-${NGINX_VERSION}.tar.gz \
    && cd nginx-${NGINX_VERSION} \
    && wget "https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_VERSION}.tar.gz" -O headers-more-nginx-module.tar.gz \
    && tar zxvf headers-more-nginx-module.tar.gz \
    && git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli \
    && cd ngx_brotli/deps/brotli \
    && mkdir out && cd out \
    && cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed .. \
    && cmake --build . --config Release --target brotlienc \
    && cd ../../../.. \
    && export CFLAGS="-m64 -march=native -mtune=native -Ofast -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" \
    && export LDFLAGS="-m64 -Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections" \
    && ./configure --prefix=/etc/nginx \
                    --sbin-path=/usr/sbin/nginx \
                    --modules-path=/usr/lib/nginx/modules \
                    --conf-path=/etc/nginx/nginx.conf \
                    --error-log-path=/var/log/nginx/error.log \
                    --http-log-path=/var/log/nginx/access.log \
                    --pid-path=/var/run/nginx.pid \
                    --lock-path=/var/run/nginx.lock \
                    --http-client-body-temp-path=/var/cache/nginx/client_temp \
                    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
                    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
                    --user=nginx \
                    --group=nginx \
                    --with-file-aio \
                    --with-threads \
                    --with-pcre \
                    --with-http_gzip_static_module \
                    --with-http_realip_module \
                    --without-http-cache \
                    --add-module=./headers-more-nginx-module-${HEADERS_MORE_VERSION} \
                    --add-module=./ngx_brotli \
    && make && make install \
    && apk add --no-cache zlib pcre && apk del .build-deps apk-tools  \
    && rm -rf $tempDir /etc/ssl /etc/apk /etc/nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && mkdir -p /var/cache/nginx && chown -R nginx:nginx /var/cache/nginx \
    && nginx -v


EXPOSE 80
COPY config/ /etc/nginx/
STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
