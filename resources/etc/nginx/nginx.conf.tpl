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

  proxy_cache_path /etc/nginx/proxy_temp_path levels=1:2 keys_zone=dogu_request_cache:10m max_size={{ .Config.GetOrDefault "proxy_max_temp_file_size" "32768m" }} inactive=10m use_temp_path=off;
  proxy_cache dogu_request_cache;

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

	# include app configuration
  include /etc/nginx/conf.d/*.conf;
}
