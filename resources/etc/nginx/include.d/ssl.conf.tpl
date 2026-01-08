listen 443 ssl;
http2 on;
server_name {{ .GlobalConfig.Get "fqdn" }};

ssl_certificate /etc/ssl/server.crt;
ssl_certificate_key /etc/ssl/server.key;

ssl_session_cache shared:SSL:50m;
ssl_session_timeout 5m;

ssl_protocols             TLSv1.2 TLSv1.3;
ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256";
ssl_conf_command Ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384;
ssl_prefer_server_ciphers on;

{{- if eq (.Config.GetOrDefault "client_auth/enabled" "false") "true" -}}
ssl_client_certificate /etc/ssl/client-ca.crt;
ssl_verify_client on;
{{- end -}}
