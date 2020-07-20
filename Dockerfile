FROM registry.cloudogu.com/official/base:3.10.3-2 as builder
LABEL maintainer="michael.behlendorf@cloudogu.com"

# dockerfile is based on https://github.com/dockerfile/nginx and https://github.com/bellycard/docker-loadbalancer

ENV NGINX_VERSION 1.17.8

COPY nginx-build /
RUN set -x \
    && apk --update add openssl-dev pcre-dev zlib-dev wget build-base \
    && mkdir /build \
    && cd /build \
    && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar -zxvf nginx-${NGINX_VERSION}.tar.gz \
    && cd /build/nginx-${NGINX_VERSION} \
    && /build.sh \
    && rm -rf /var/cache/apk/* /build


FROM registry.cloudogu.com/official/base:3.10.3-2
LABEL maintainer="sebastian.sdorra@cloudogu.com" \
      name="official/nginx" \
      version="1.17.8-3"

ENV CES_CONFD_VERSION=0.3.1 \
    WARP_MENU_VERSION=1.0.2 \
    CES_ABOUT_VERSION=0.2.2 \
    CES_THEME_VERSION=0d20c1b1d5518af475cddb33713e58ebf57f5599 \
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
# volumes used to avoid writing to containers writable layer https://docs.docker.com/storage/
VOLUME ["/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# Define working directory.
WORKDIR /etc/nginx

HEALTHCHECK CMD doguctl healthy nginx || exit 1

# Define default command.
ENTRYPOINT ["/startup.sh"]

# Expose ports.
EXPOSE 80
EXPOSE 443
