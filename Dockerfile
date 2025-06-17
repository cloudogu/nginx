FROM node:lts-alpine as templating

ENV WORKDIR=/template \
    # Used in template to invalidate caches - do not remove. The release script will auto update this line
    VERSION="1.28.0-2"

RUN mkdir -p ${WORKDIR}
WORKDIR ${WORKDIR}

COPY theme-build ${WORKDIR}/
COPY resources ${WORKDIR}/resources

RUN yarn install
RUN node template-colors.js  ${WORKDIR}/resources/var/www/html/styles/default.css.tpl ${WORKDIR}/build/default.css
RUN node template-error-pages.js ${WORKDIR}/resources/var/www/html/errors/error-page.html.tpl ${WORKDIR}/build/errors

FROM registry.cloudogu.com/official/base:3.22.0-2 as builder
LABEL maintainer="hello@cloudogu.com"

# dockerfile is based on https://github.com/dockerfile/nginx and https://github.com/bellycard/docker-loadbalancer
ENV NGINX_VERSION=1.28.0 \
    NGINX_TAR_SHA256="c6b5c6b086c0df9d3ca3ff5e084c1d0ef909e6038279c71c1c3e985f576ff76a" \
    CES_CONFD_VERSION=0.11.0 \
    CES_CONFD_TAR_SHA256="85809a3e9e0b56d58c53f958872809eab1026124a73a06eedfcdeba9ca73ec9a" \
    WARP_MENU_VERSION=2.0.3 \
    WARP_MENU_ZIP_SHA256="8dfd023579728b6786bdb4664fb6d3e629717d9d2d27cdd4b365f9a844f1858c" \
    CES_ABOUT_VERSION="0.7.0" \
    CES_ABOUT_TAR_SHA256="fcfdfb86dac75d5ae751cc0e8c3436ecee12f0d5ed830897c4f61029ae1df27e"

WORKDIR /build

COPY nginx-build /
RUN set -x -o errexit \
    && set -o nounset \
    && set -o pipefail \
    && apk update \
    && apk upgrade \
    && apk --update add openssl-dev pcre-dev zlib-dev wget build-base \
    && wget --progress=bar:force:noscroll http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -O /tmp/nginx-${NGINX_VERSION}.tar.gz \
    && echo "${NGINX_TAR_SHA256} */tmp/nginx-${NGINX_VERSION}.tar.gz" | sha256sum -c - \
    && tar -zxvf /tmp/nginx-${NGINX_VERSION}.tar.gz -C /build \
    && cd /build/nginx-${NGINX_VERSION} \
    && /build.sh

# install ces-confd
RUN wget --progress=bar:force:noscroll -O "/tmp/ces-confd-${CES_CONFD_VERSION}.tar.gz" https://github.com/cloudogu/ces-confd/releases/download/v${CES_CONFD_VERSION}/ces-confd-${CES_CONFD_VERSION}.tar.gz \
    && echo "${CES_CONFD_TAR_SHA256} */tmp/ces-confd-${CES_CONFD_VERSION}.tar.gz" | sha256sum -c - \
    && mkdir -p /build/usr/bin \
    && tar -xzvf /tmp/ces-confd-${CES_CONFD_VERSION}.tar.gz -C /build/usr/bin \
    && chmod +x /build/usr/bin/ces-confd \
    && mkdir -p /build/var/log/nginx \
    && mkdir -p /build/var/www/html \
    && mkdir -p /build/var/www/customhtml

# install ces-about page
RUN wget --progress=bar:force:noscroll -O /tmp/ces-about-v${CES_ABOUT_VERSION}.tar.gz https://github.com/cloudogu/ces-about/releases/download/v${CES_ABOUT_VERSION}/ces-about_v${CES_ABOUT_VERSION}.tar.gz \
    && echo "${CES_ABOUT_TAR_SHA256} */tmp/ces-about-v${CES_ABOUT_VERSION}.tar.gz" | sha256sum -c - \
    && tar -xzvf /tmp/ces-about-v${CES_ABOUT_VERSION}.tar.gz -C /build/var/www/html \
    && mkdir -p /build/etc/nginx/include.d/ \
    && cp /build/var/www/html/routes/ces-about-routes.conf /build/etc/nginx/include.d/ \
    && rm -rf /build/var/www/html/routes

# install warp menu
RUN wget --progress=bar:force:noscroll -O /tmp/warp.zip https://github.com/cloudogu/warp-menu/releases/download/v${WARP_MENU_VERSION}/warp-v${WARP_MENU_VERSION}.zip \
    && echo "${WARP_MENU_ZIP_SHA256} */tmp/warp.zip" | sha256sum -c - \
    && unzip /tmp/warp.zip -d /build/var/www/html

FROM registry.cloudogu.com/official/base:3.22.0-2
LABEL maintainer="hello@cloudogu.com" \
      NAME="official/nginx" \
      VERSION="1.28.0-2"

ENV CES_MAINTENANCE_MODE=false \
    # Used in template to invalidate caches - do not remove. The release script will auto update this line
    VERSION="1.28.0-2"

RUN set -x -o errexit \
 && set -o nounset \
 && set -o pipefail \
 && apk update \
 && apk upgrade \
 # install required packages
 && apk --update add --no-cache openssl pcre zlib \
 # add nginx user
 && adduser nginx -D

# copy files
COPY resources /
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /build /

# copy templated files
COPY --from=templating /template/build/default.css /var/www/html/styles/default.css
COPY --from=templating /template/build/errors /var/www/html/errors

# redirect logs
# cannot be done via builder container as symlinks cannot get copied
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Compared to the bind mounted volumes we declare in the dogu.json,
# the volumes declared here are not mounted to the dogu if the container is destroyed/recreated,
# e.g. after a dogu upgrade
VOLUME ["/var/nginx/conf.d/", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# Define working directory.
WORKDIR /etc/nginx

HEALTHCHECK --interval=5s CMD doguctl healthy nginx || exit 1

# Define default command.
ENTRYPOINT ["/startup.sh"]

# Expose ports.
EXPOSE 80
EXPOSE 443
