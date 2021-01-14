FROM registry.cloudogu.com/official/base:3.11.6-3 as builder
LABEL maintainer="michael.behlendorf@cloudogu.com"

# dockerfile is based on https://github.com/dockerfile/nginx and https://github.com/bellycard/docker-loadbalancer

ENV NGINX_VERSION 1.17.8
ENV NGINX_TAR_SHA256="97d23ecf6d5150b30e284b40e8a6f7e3bb5be6b601e373a4d013768d5a25965b"

COPY nginx-build /
RUN set -x \
    && apk --update add openssl-dev pcre-dev zlib-dev wget build-base \
    && mkdir /build \
    && cd /build \
    && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && echo "${NGINX_TAR_SHA256} *nginx-${NGINX_VERSION}.tar.gz" | sha256sum -c - \
    && tar -zxvf nginx-${NGINX_VERSION}.tar.gz \
    && cd /build/nginx-${NGINX_VERSION} \
    && /build.sh \
    && rm -rf /var/cache/apk/* /build


FROM registry.cloudogu.com/official/base:3.10.3-2
LABEL maintainer="sebastian.sdorra@cloudogu.com" \
      NAME="official/nginx" \
      VERSION="1.17.8-8"

ENV CES_CONFD_VERSION=0.4.0 \
    CES_CONFD_TAR_SHA256="211f754b31a05332cb15ef787c421fc3a0f5fa955b89ea0976397952fcfb2287" \
    WARP_MENU_VERSION=1.0.4 \
    WARP_MENU_TAR_SHA256="a5428b2adc1973724b0da93a0e67b06d2e9566c026733e20b4e39573a6148cd1" \
    CES_ABOUT_VERSION=0.2.2 \
    CES_ABOUT_TAR_SHA256="9926649be62d8d4667b2e7e6d1e3a00ebec1c4bbc5b80a0e830f7be21219d496" \
    CES_THEME_VERSION=0d20c1b1d5518af475cddb33713e58ebf57f5599 \
    CES_THEME_TAR_SHA256="a2ae6ab465b629f59814d3898abdab45119e2de7ef44fcac2b054debbcb1c66a" \
    CES_MAINTENANCE_MODE=false

RUN set -x \
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

# Define mountable directories.
# volumes used to avoid writing to containers writable layer https://docs.docker.com/storage/
VOLUME ["/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html", "var/www/customhtml"]

# Define working directory.
WORKDIR /etc/nginx

HEALTHCHECK CMD doguctl healthy nginx || exit 1

# Define default command.
ENTRYPOINT ["/startup.sh"]

# Expose ports.
EXPOSE 80
EXPOSE 443
