#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

CFLAGS="-g -O0" ./configure \
    --with-debug \
    --with-http_ssl_module \
    --with-http_gzip_static_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --prefix=/etc/nginx \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --sbin-path=/usr/sbin/nginx
make
make install
