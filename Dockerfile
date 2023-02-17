FROM registry.cloudogu.com/official/base:3.15.3-1 as builder
LABEL maintainer="hello@cloudogu.com"

# dockerfile is based on https://github.com/dockerfile/nginx and https://github.com/bellycard/docker-loadbalancer

ENV NGINX_VERSION 1.23.2
ENV NGINX_TAR_SHA256="a80cc272d3d72aaee70aa8b517b4862a635c0256790434dbfc4d618a999b0b46"

COPY nginx-build /
RUN set -x -o errexit \
    && set -o nounset \
    && set -o pipefail \
    && apk update \
    && apk upgrade \
    && apk --update add openssl-dev pcre-dev zlib-dev wget build-base \
    && mkdir /build \
    && cd /build \
    && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && echo "${NGINX_TAR_SHA256} *nginx-${NGINX_VERSION}.tar.gz" | sha256sum -c - \
    && tar -zxvf nginx-${NGINX_VERSION}.tar.gz \
    && cd /build/nginx-${NGINX_VERSION} \
    && /build.sh \
    && rm -rf /var/cache/apk/* /build


FROM registry.cloudogu.com/official/base:3.15.3-1
LABEL maintainer="hello@cloudogu.com" \
      NAME="official/nginx" \
      VERSION="1.23.2-2"

ENV CES_CONFD_VERSION=0.8.0 \
    CES_CONFD_TAR_SHA256="365a4033e80af6953d5b6513296a828dfd772a6640533bb51dd9abd34a1e53e8" \
    WARP_MENU_VERSION=1.7.2 \
    WARP_MENU_TAR_SHA256="0f89f3a4bcd24779b792bab34e77c60e27b9142c402e168013711f3094045726" \
    CES_ABOUT_VERSION=0.2.2 \
    CES_ABOUT_TAR_SHA256="9926649be62d8d4667b2e7e6d1e3a00ebec1c4bbc5b80a0e830f7be21219d496" \
    CES_THEME_VERSION=v0.7.0 \
    CES_THEME_TAR_SHA256="d3c8ba654cdaccff8fa3202f3958ac0c61156fb25a288d6008354fae75227941" \
    CES_MAINTENANCE_MODE=false

RUN set -x -o errexit \
 && set -o nounset \
 && set -o pipefail \
 && apk update \
 && apk upgrade \
 # install required packages
 && apk --update add openssl pcre zlib \
 # add nginx user
 && adduser nginx -D \
 # install ces-confd
 && curl -Lsk https://github.com/cloudogu/ces-confd/releases/download/v${CES_CONFD_VERSION}/ces-confd-${CES_CONFD_VERSION}.tar.gz -o "ces-confd-${CES_CONFD_VERSION}.tar.gz" \
 && echo "${CES_CONFD_TAR_SHA256} *ces-confd-${CES_CONFD_VERSION}.tar.gz" | sha256sum -c - \
 && tar -xzvf ces-confd-${CES_CONFD_VERSION}.tar.gz -O > /usr/bin/ces-confd \
 && chmod +x /usr/bin/ces-confd \
 && mkdir -p /var/log/nginx \
 && mkdir -p /var/www/html \
 && mkdir -p /var/www/customhtml \
 # install ces-about page
 && curl -Lsk https://github.com/cloudogu/ces-about/releases/download/v${CES_ABOUT_VERSION}/ces-about-v${CES_ABOUT_VERSION}.tar.gz -o ces-about-v${CES_ABOUT_VERSION}.tar.gz \
 && echo "${CES_ABOUT_TAR_SHA256} *ces-about-v${CES_ABOUT_VERSION}.tar.gz" | sha256sum -c - \
 && tar -xzvf ces-about-v${CES_ABOUT_VERSION}.tar.gz -C /var/www/html \
 && sed -i 's@base href=".*"@base href="/info/"@' /var/www/html/info/index.html \
 # install warp menu
 && curl -Lsk https://github.com/cloudogu/warp-menu/releases/download/v${WARP_MENU_VERSION}/warp-v${WARP_MENU_VERSION}.zip -o /tmp/warp.zip \
 && echo "${WARP_MENU_TAR_SHA256} */tmp/warp.zip" | sha256sum -c - \
 && unzip /tmp/warp.zip -d /var/www/html \
 # install custom error pages
 && curl -Lsk https://github.com/cloudogu/ces-theme/archive/${CES_THEME_VERSION}.zip -o /tmp/theme.zip \
 && echo "${CES_THEME_TAR_SHA256} */tmp/theme.zip" | sha256sum -c - \
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

# Volumes are used to avoid writing to containers writable layer https://docs.docker.com/storage/
# Compared to the bind mounted volumes we declare in the dogu.json,
# the volumes declared here are not mounted to the dogu if the container is destroyed/recreated,
# e.g. after a dogu upgrade
VOLUME ["/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# Define working directory.
WORKDIR /etc/nginx

HEALTHCHECK --interval=5s CMD doguctl healthy nginx || exit 1

# Define default command.
ENTRYPOINT ["/startup.sh"]

# Expose ports.
EXPOSE 80
EXPOSE 443
