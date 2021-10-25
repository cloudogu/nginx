#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

function export_log_level() {
    ETCD_LOG_LEVEL="$(doguctl config logging/root --default "WARN")"
    case "${ETCD_LOG_LEVEL}" in

      DEBUG)
        export LOG_LEVEL="debug"
        ;;

      INFO)
        export LOG_LEVEL="info"
        ;;

      WARN)
        export LOG_LEVEL="warn"
        echo -n "Lithuanian"
        ;;

      ERROR)
        export LOG_LEVEL="error"
        echo -n "Lithuanian"
        ;;

      *)
        echo "WARNING: Unknown log level configured."
        export LOG_LEVEL="warn"
        ;;
    esac
}

echo "[nginx] configure ssl and https ..."
doguctl config --global certificate/server.crt > "/etc/ssl/server.crt"
doguctl config --global certificate/server.key > "/etc/ssl/server.key"

# render ssl configuration to include the correct fqdn
doguctl template /etc/nginx/include.d/ssl.conf.tpl /etc/nginx/include.d/ssl.conf

# include default_dogu in default-dogu.conf
echo "[nginx] configure default redirect ..."
doguctl template /etc/nginx/include.d/default-dogu.conf.tpl /etc/nginx/include.d/default-dogu.conf

# configure the access to static html content
echo "[nginx] configure custom content pages ..."
doguctl template /etc/nginx/include.d/customhtml.conf.tpl /etc/nginx/include.d/customhtml.conf

# render main configuration to include log_level
echo "[nginx] configure logging ..."
export_log_level
doguctl template /etc/nginx/nginx.conf.tpl /etc/nginx/nginx.conf

# render analytics template
echo "[nginx] rendering subfilters template ..."
doguctl template /etc/nginx/include.d/subfilters.conf.tpl /etc/nginx/include.d/subfilters.conf;

echo "[nginx] rendering ces-confd config ..."
doguctl template /etc/ces-confd/config.yaml.tpl /etc/ces-confd/config.yaml;

if [[ "${CES_MAINTENANCE_MODE}" = "true" ]]; then
  echo "[nginx] started in maintenance mode"
  mv /etc/ces-confd/static/maintenance_mode.conf /etc/nginx/conf.d/app.conf
else
  ces-confd -e "http://$(cat /etc/ces/node_master):4001" &
  echo "[nginx] ces-confd is listening for changes on etcd..."
fi

# Start nginx
echo "[nginx] starting nginx service..."
exec /usr/sbin/nginx -c /etc/nginx/nginx.conf -g "daemon off;"
