MAKEFILES_VERSION=9.5.2

.DEFAULT_GOAL:=dogu-release

include build/make/variables.mk
include build/make/self-update.mk
include build/make/release.mk
include build/make/prerelease.mk
include build/make/version-sha.mk

NGINX_VERSION=$(shell grep NGINX_VERSION= Dockerfile | sed 's/.*NGINX_VERSION=\([^ ]*\).*/\1/g')
CES_CONFD_VERSION=$(shell grep CES_CONFD_VERSION= Dockerfile | sed 's/.*CES_CONFD_VERSION=\([^ ]*\).*/\1/g')
WARP_MENU_VERSION=$(shell grep WARP_MENU_VERSION= Dockerfile | sed 's/.*WARP_MENU_VERSION=\([^ ]*\).*/\1/g')
CES_ABOUT_VERSION=$(shell grep CES_ABOUT_VERSION= Dockerfile | sed 's/.*CES_ABOUT_VERSION=\([^ ]*\).*/\1/g')
CES_THEME_VERSION=$(shell grep CES_THEME_VERSION= Dockerfile | sed 's/.*CES_THEME_VERSION=\([^ ]*\).*/\1/g')


.PHONY: sums
sums: ## Print out all versions
	@echo "nginx"
	@make --no-print-directory sha-sum SHA_SUM_URL=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
	@echo "confd"
	@make --no-print-directory sha-sum SHA_SUM_URL=https://github.com/cloudogu/ces-confd/releases/download/v${CES_CONFD_VERSION}/ces-confd-${CES_CONFD_VERSION}.tar.gz
	@echo "warp-menu"
	@make --no-print-directory sha-sum SHA_SUM_URL=https://github.com/cloudogu/warp-menu/releases/download/v${WARP_MENU_VERSION}/warp-v${WARP_MENU_VERSION}.zip
	@echo "ces-about"
	@make --no-print-directory sha-sum SHA_SUM_URL=https://github.com/cloudogu/ces-about/releases/download/v${CES_ABOUT_VERSION}/ces-about-v${CES_ABOUT_VERSION}.tar.gz
	@echo "ces-theme"
	@make --no-print-directory sha-sum SHA_SUM_URL=https://github.com/cloudogu/ces-theme/archive/v${CES_THEME_VERSION}.zip
