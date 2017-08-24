#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

source /etc/ces/functions.sh

echo "[nginx] configure ssl and https ..."
doguctl config --global certificate/server.crt > "/etc/ssl/server.crt"
doguctl config --global certificate/server.key > "/etc/ssl/server.key"

# include fqdn in ssl.conf
FQDN=$(doguctl config --global fqdn)
render_template "/etc/nginx/include.d/ssl.conf.tpl" > "/etc/nginx/include.d/ssl.conf"

echo "[nginx] configure default redirect ..."
# include default_dogu in default-dogu.conf
if ! DEFAULT_DOGU=$(doguctl config --global default_dogu); then
  DEFAULT_DOGU="cockpit"
fi
render_template "/etc/nginx/include.d/default-dogu.conf.tpl" > "/etc/nginx/include.d/default-dogu.conf"

ces-confd -e "http://$(cat /etc/ces/node_master):4001" &
echo "[nginx] ces-confd is listening for changes on etcd..."

# Start nginx
echo "[nginx] starting nginx service..."
exec /usr/sbin/nginx -c /etc/nginx/nginx.conf -g "daemon off;"
