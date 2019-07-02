FROM registry.cloudogu.com/official/base:3.9.4-1 as builder
LABEL maintainer="michael.behlendorf@cloudogu.com"

# dockerfile is based on https://github.com/dockerfile/nginx and https://github.com/bellycard/docker-loadbalancer

ENV NGINX_VERSION 1.13.11

COPY build /
RUN set -x \
    && apk --update add openssl-dev pcre-dev zlib-dev wget build-base \
    && mkdir /build \
    && cd /build \
    && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar -zxvf nginx-${NGINX_VERSION}.tar.gz \
    && cd /build/nginx-${NGINX_VERSION} \
    && /build.sh \
    && rm -rf /var/cache/apk/* /build


FROM registry.cloudogu.com/official/base:3.9.4-1
LABEL maintainer="sebastian.sdorra@cloudogu.com"

ENV CES_CONFD_VERSION=0.3.1 \
    WARP_MENU_VERSION=0.4.3 \
    CES_ABOUT_VERSION=0.2.1 \
    CES_THEME_VERSION=d7a0865917f25d3dbf78777d81d96aaab845f622 \
    CES_MAINTENANCE_MODE=false

RUN set -x \
 # install required packages
 && apk --update add openssl pcre zlib \
 # add nginx user
 && adduser nginx -D \
 # install ces-confd
 && curl -Lsk https://github.com/cloudogu/ces-confd/releases/download/v${CES_CONFD_VERSION}/ces-confd-v${CES_CONFD_VERSION}.tar.gz | gunzip | tar -x -O > /usr/bin/ces-confd \
 && chmod +x /usr/bin/ces-confd \
 && mkdir -p /var/log/nginx \
 && mkdir -p /var/www/html \
 # install ces-about page
 && curl -Lsk https://github.com/cloudogu/ces-about/releases/download/v${CES_ABOUT_VERSION}/ces-about-v${CES_ABOUT_VERSION}.tar.gz | gunzip | tar -xv -C /var/www/html \
 && sed -i 's@base href=".*"@base href="/info/"@' /var/www/html/info/index.html \
 # install warp menu
 && curl -Lsk https://github.com/cloudogu/warp-menu/releases/download/v${WARP_MENU_VERSION}/warp-v${WARP_MENU_VERSION}.zip -o /tmp/warp.zip \
 && unzip /tmp/warp.zip -d /var/www/html \
 # install custom error pages
 && curl -Lsk https://github.com/cloudogu/ces-theme/archive/${CES_THEME_VERSION}.zip -o /tmp/theme.zip \
 && mkdir /var/www/html/errors \
 && unzip /tmp/theme.zip -d /tmp/theme \
 && mv /tmp/theme/ces-theme-*/dist/errors/* /var/www/html/errors \
 && rm -rf /tmp/theme.zip /tmp/theme \
 # redirect logs
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log \
 # cleanup apk cache
 && rm -rf /var/cache/apk/*

# copy files
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY resources /

# Define mountable directories.
# TODO check if any of the volumes are required
VOLUME ["/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# Define working directory.
WORKDIR /etc/nginx

# Define default command.
ENTRYPOINT ["/startup.sh"]

# Expose ports.
EXPOSE 80
EXPOSE 443
