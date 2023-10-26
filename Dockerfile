FROM registry.cloudogu.com/official/base:3.17.3-2 as builder
LABEL maintainer="hello@cloudogu.com"

# dockerfile is based on https://github.com/dockerfile/nginx and https://github.com/bellycard/docker-loadbalancer

ENV NGINX_VERSION=1.23.2 \
    NGINX_TAR_SHA256="a80cc272d3d72aaee70aa8b517b4862a635c0256790434dbfc4d618a999b0b46" \
    CES_CONFD_VERSION=0.8.0 \
    CES_CONFD_TAR_SHA256="365a4033e80af6953d5b6513296a828dfd772a6640533bb51dd9abd34a1e53e8" \
    WARP_MENU_VERSION=1.7.3 \
    WARP_MENU_TAR_SHA256="b3ed4b50b1b9a739a4430d88975b5e3030c5e542c0739ed6b72d7eb8fd9a7b18" \
    CES_ABOUT_VERSION="0.4.0-rc2" \
    CES_ABOUT_TAR_SHA256="3965bb8b0014cf18d3e1b5db8e31ebfc7781d82c2ac4ec6bfbf944be6b3e637d" \
    CES_THEME_VERSION=0.7.0 \
    CES_THEME_TAR_SHA256="d3c8ba654cdaccff8fa3202f3958ac0c61156fb25a288d6008354fae75227941"

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

# install custom error pages
RUN wget --progress=bar:force:noscroll -O /tmp/theme.zip https://github.com/cloudogu/ces-theme/archive/v${CES_THEME_VERSION}.zip \
    && echo "${CES_THEME_TAR_SHA256} */tmp/theme.zip" | sha256sum -c - \
    && unzip /tmp/theme.zip -d /tmp/theme \
    && cp -r /tmp/theme/ces-theme-${CES_THEME_VERSION}/dist/errors /build/var/www/html

FROM registry.cloudogu.com/official/base:3.17.3-2
LABEL maintainer="hello@cloudogu.com" \
      NAME="official/nginx" \
      VERSION="1.23.2-7"

ENV CES_MAINTENANCE_MODE=false

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

# redirect logs
# cannot be done via builder container as symlinks cannot get copied
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

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
