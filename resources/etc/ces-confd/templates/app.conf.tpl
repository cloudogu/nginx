{{define "service-block"}}
    location /{{.Location}} {
    {{if eq .HealthStatus "healthy" "" }}
        {{ if .Rewrite }}
            rewrite ^/{{ .Rewrite.Pattern }}(/|$)(.*) {{ .Rewrite.Rewrite }}/$2 break;
        {{end}}
        {{ if eq .ProxyBuffering "off" }}proxy_buffering off;{{ end }}
        proxy_pass {{.URL}};
    {{else}}
        error_page 503 /errors/starting.html;
        return 503;
    {{end}}
    }
{{end}}

server {
  include /etc/nginx/include.d/ssl.conf;
  include /etc/nginx/include.d/errors.conf;
  include /etc/nginx/include.d/warp.conf;
  include /etc/nginx/include.d/whitelabel.conf;
  include /etc/nginx/include.d/robots.conf;
  include /etc/nginx/app.conf.d/*.conf;

  # default proxy settings
  proxy_set_header Host $http_host;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto https;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Scheme $scheme;

  # proxy keep alive settings
  # https://github.com/cloudogu/ecosystem/issues/298
  # https://stackoverflow.com/questions/28347184/upstream-timed-out-110-connection-timed-out-for-static-content
  proxy_http_version 1.1;

  # nginx.conf map handles connection_upgrade http_upgrade
  proxy_set_header Connection $connection_upgrade;
  proxy_set_header Upgrade $http_upgrade;

  proxy_read_timeout 1d;

  # disable gzip encoding for proxy applications
  proxy_set_header Accept-Encoding identity;

{{if .Maintenance}}
    {{range .Services}}
        {{if eq .Location "ces-exporter" }}
            # allow ces-exporter access in maintenance mode
            {{template "service-block" .}}
        {{end}}
    {{end}}

    # show 503 for all other services in maintenance mode
    location / {
      return 503;
    }
{{else}}

  include /etc/nginx/include.d/info.conf;
  include /etc/nginx/include.d/subfilters.conf;
  include /etc/nginx/include.d/default-dogu.conf;
  include /etc/nginx/include.d/customhtml.conf;

  # services
  {{range .Services}}
      {{template "service-block" .}}
  {{end}}
  # end of services

{{end}}
}
