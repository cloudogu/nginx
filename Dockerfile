FROM node:lts-alpine as templating

ENV WORKDIR=/template \
    # Used in template to invalidate caches - do not remove. The release script will auto update this line
    VERSION="1.26.1-9"

RUN mkdir -p ${WORKDIR}
WORKDIR ${WORKDIR}

COPY theme-build ${WORKDIR}/
COPY resources ${WORKDIR}/resources

RUN yarn install
RUN node template-colors.js  ${WORKDIR}/resources/var/www/html/styles/default.css.tpl ${WORKDIR}/build/default.css
RUN node template-error-pages.js ${WORKDIR}/resources/var/www/html/errors/error-page.html.tpl ${WORKDIR}/build/errors

FROM registry.cloudogu.com/official/base:3.20.2-1 as builder
LABEL maintainer="hello@cloudogu.com"

# dockerfile is based on https://github.com/dockerfile/nginx and https://github.com/bellycard/docker-loadbalancer
ENV NGINX_VERSION=1.26.1 \
    NGINX_TAR_SHA256="f9187468ff2eb159260bfd53867c25ff8e334726237acf227b9e870e53d3e36b" \
    CES_CONFD_VERSION=0.9.0 \
    CES_CONFD_TAR_SHA256="8507f40824562b8d2c1f32afb43ce1aad576a82febd2f97bd2cf31b0753a8cbd" \
    WARP_MENU_VERSION=2.0.0 \
    WARP_MENU_TAR_SHA256="51a1010ec0f82b634999e48976d7fec98e6eb574a4401a841cd53f8cd0e14040" \
    CES_ABOUT_VERSION="0.5.0" \
    CES_ABOUT_TAR_SHA256="c4664340a248d9c2d9333a9a9df7aa9141ebeb40c051d65f78c57f2439b6f07d"

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
    && echo "${WARP_MENU_TAR_SHA256} */tmp/warp.zip" | sha256sum -c - \
    && unzip /tmp/warp.zip -d /build/var/www/html

FROM registry.cloudogu.com/official/base:3.20.2-1
LABEL maintainer="hello@cloudogu.com" \
      NAME="official/nginx" \
      VERSION="1.26.1-9"

ENV CES_MAINTENANCE_MODE=false \
    # Used in template to invalidate caches - do not remove. The release script will auto update this line
    VERSION="1.26.1-9"

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
