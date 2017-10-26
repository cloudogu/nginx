#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

source /etc/ces/functions.sh

echo "[nginx] configure ssl and https ..."
doguctl config --global certificate/server.crt > "/etc/ssl/server.crt"
doguctl config --global certificate/server.key > "/etc/ssl/server.key"

# render ssl configuration to include the correct fqdn
doguctl template /etc/nginx/include.d/ssl.conf.tpl /etc/nginx/include.d/ssl.conf

# include default_dogu in default-dogu.conf
echo "[nginx] configure default redirect ..."
doguctl template /etc/nginx/include.d/default-dogu.conf.tpl /etc/nginx/include.d/default-dogu.conf

# render main configuration to include log_level
echo "[nginx] configure logging ..."
doguctl template /etc/nginx/nginx.conf.tpl /etc/nginx/nginx.conf

ces-confd -e "http://$(cat /etc/ces/node_master):4001" &
echo "[nginx] ces-confd is listening for changes on etcd..."

# Start nginx
echo "[nginx] starting nginx service..."
exec /usr/sbin/nginx -c /etc/nginx/nginx.conf -g "daemon off;"
