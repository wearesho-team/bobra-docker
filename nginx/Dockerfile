FROM alpine:3.23

LABEL maintainer="Wearesho Team <cto@wearesho.com>"

ENV NGINX_VERSION=1.31.4
ENV HEADERS_MORE_VERSION=0.40

# --- Target architecture and CPU tuning --------------------------------------
# TARGETARCH is filled in automatically by `docker buildx build --platform ...`.
# It is empty for a plain `docker build`, where we fall back to the build host.
ARG TARGETARCH

# Baseline CPU targets, used instead of `-march=native`. Native tuning pins the
# binary to the exact CPU of the machine that built it, so the image dies with
# SIGILL anywhere else - including under emulation on Apple Silicon.
# Change the baseline here, or per build with --build-arg.
#   x86-64-v2 = SSE4.2 / POPCNT  (Nehalem+, 2008)
#   x86-64-v3 = AVX2 / FMA       (Haswell+, 2013)  <- current default
#   x86-64-v4 = AVX-512          (Skylake-SP+, 2017)
ARG CPU_MARCH_AMD64=x86-64-v3
# armv8-a is the aarch64 baseline and already mandates NEON, so every arm64 CPU
# (Apple Silicon, Graviton, Ampere) can run it.
ARG CPU_MARCH_ARM64=armv8-a

# Replaces both defaults above when set. Escape hatch for a single-host build,
# e.g. --build-arg CPU_FLAGS="-march=native -mtune=native".
ARG CPU_FLAGS=""

RUN set -x \
    # Resolve the tuning flags for the architecture this image is built for.
    && if [ -z "${CPU_FLAGS}" ]; then \
         case "${TARGETARCH:-$(apk --print-arch)}" in \
           amd64|x86_64)  CPU_FLAGS="-march=${CPU_MARCH_AMD64} -mtune=generic" ;; \
           arm64|aarch64) CPU_FLAGS="-march=${CPU_MARCH_ARM64} -mtune=generic" ;; \
           *) echo "unsupported architecture: ${TARGETARCH}" >&2 && exit 1 ;; \
         esac; \
       fi \
    # -O3 rather than -Ofast: -Ofast implies -ffast-math, which gains nothing
    # here (no TLS module is built, the hot path is integer compression code).
    && OPT_CFLAGS="-O3 ${CPU_FLAGS} -flto -funroll-loops -ffunction-sections -fdata-sections" \
    # --gc-sections is a linker flag, and -flto has to be repeated at link time
    # for LTO to actually run.
    && OPT_LDFLAGS="-Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections -flto" \
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
    && cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="${OPT_CFLAGS}" -DCMAKE_CXX_FLAGS="${OPT_CFLAGS}" -DCMAKE_INSTALL_PREFIX=./installed .. \
    && cmake --build . --config Release --target brotlienc \
    && cd ../../../.. \
    # Passed through nginx's own options rather than the CFLAGS/LDFLAGS
    # environment, which its configure script does not read - the linker flags
    # below were silently dropped before. As a side effect `nginx -V` now
    # reports the flags the binary was actually built with.
    && ./configure --with-cc-opt="${OPT_CFLAGS}" \
                    --with-ld-opt="${OPT_LDFLAGS}" \
                    --prefix=/etc/nginx \
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
    && nginx -V


EXPOSE 80
COPY config/ /etc/nginx/
STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
