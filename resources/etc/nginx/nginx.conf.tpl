user  nginx;
worker_processes  2;

error_log  /var/log/nginx/error.log {{ .Env.Get "LOG_LEVEL" }};
pid        /var/run/nginx.pid;

events {
  worker_connections  2048;
}

http {
  ##
  # Basic Settings
  ##
  sendfile on;
  tcp_nopush on;
  tcp_nodelay on;
  keepalive_timeout 65;
  types_hash_max_size 2048;
  client_max_body_size 0;
	# server_tokens off;
  include       /etc/nginx/include.d/mime.types;
  default_type  application/octet-stream;

  # Limit download size to 32gb
  proxy_max_temp_file_size 32768m;

  # if the request wants to ugrade to websocket we map the header and set the Upgrade header
  map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
  }

  # logging
  {{ if not (.Config.Exists "disable_access_log") }}
  log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
  access_log  /var/log/nginx/access.log  main;
  {{end}}

	##
	# Gzip Settings
	##
	gzip on;
	gzip_disable "msie6";

	gzip_vary on;
	gzip_proxied any;
	gzip_comp_level 6;
	gzip_buffers 16 8k;
	gzip_http_version 1.1;
	gzip_types text/plain text/css application/json application/x-javascript application/javascript text/xml application/xml application/xml+rss text/javascript;

# proxy buffers
  {{ if  (.Config.Exists "buffer/proxy_buffer_size") }}
    proxy_buffer_size   {{ .Config.GetOrDefault "buffer/proxy_buffer_size" "4k" }};
  {{end}}
  {{ if  (.Config.Exists "buffer/proxy_buffers") }}
    proxy_buffers   {{ .Config.GetOrDefault "buffer/proxy_buffers" "8 8k" }};
  {{end}}
  {{ if  (.Config.Exists "buffer/proxy_busy_buffers_size") }}
    proxy_busy_buffers_size   {{ .Config.GetOrDefault "buffer/proxy_busy_buffers_size" "32k" }};
  {{end}}

	# include app configuration
  include /etc/nginx/conf.d/*.conf;
  include {{ .Env.Get "APPCONF_VOL_DIR" }}/*.conf;

  {{- if eq (.Config.GetOrDefault "client_auth/enabled" "false") "true" -}}
    # mark internal requests coming from the docker network
    geo $is_internal {
      default 0;
      172.18.0.1/32 1;
      127.0.0.1/32  1;
    }

    # allow only all internal requests or external requests if mTLS was successful
    map "$is_internal:$ssl_client_verify" $access_allowed {
      default 0;

      # internal always allowed
      "1:NONE"    1;
      "1:FAILED"  1;
      "1:SUCCESS" 1;

      # external only allowed, if mTLS was successful
      "0:SUCCESS" 1;
    }

  {{- end -}}

}
