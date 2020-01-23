listen 443 ssl http2;
server_name {{ .GlobalConfig.Get "fqdn" }};

ssl_certificate /etc/ssl/server.crt;
ssl_certificate_key /etc/ssl/server.key;

ssl_session_cache shared:SSL:50m;
ssl_session_timeout 5m;

ssl_protocols             TLSv1.2 TLSv1.3;
ssl_ciphers 'TLS-CHACHA20-POLY1305-SHA256:TLS-AES-256-GCM-SHA384:TLS-AES-128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256';
ssl_prefer_server_ciphers on;
