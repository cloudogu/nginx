#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

echo "                                     ./////,                    "
echo "                                 ./////==//////*                "
echo "                                ////.  ___   ////.              "
echo "                         ,**,. ////  ,////A,  */// ,**,.        "
echo "                    ,/////////////*  */////*  *////////////A    "
echo "                   ////'        \VA.   '|'   .///'       '///*  "
echo "                  *///  .*///*,         |         .*//*,   ///* "
echo "                  (///  (//////)**--_./////_----*//////)   ///) "
echo "                   V///   '°°°°      (/////)      °°°°'   ////  "
echo "                    V/////(////////\. '°°°' ./////////(///(/'   "
echo "                       'V/(/////////////////////////////V'      "

function export_log_level() {
    ETCD_LOG_LEVEL="$(doguctl config logging/root --default "WARN")"
    echo "Found etcd log level: ${ETCD_LOG_LEVEL}"

    # The log level is exported for `doguctl template`
    # The format is almost the same, except the case. The etcd-format is all uppercase, the configuration format
    # is all lower case.
    export LOG_LEVEL="${ETCD_LOG_LEVEL,,}"

    echo "Set dogu log level to : ${LOG_LEVEL}"
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
