server {
  include /etc/nginx/include.d/ssl.conf;
  include /etc/nginx/include.d/errors.conf;
  include /etc/nginx/include.d/robots.conf;

{{if .Maintenance}}
  location / {
    return 503;
  }
{{else}}

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
  proxy_set_header Connection "";

  # disable gzip encoding for proxy applications
  proxy_set_header Accept-Encoding identity;

  include /etc/nginx/include.d/info.conf;
  include /etc/nginx/include.d/subfilters.conf;
  include /etc/nginx/include.d/default-dogu.conf;  
  include /etc/nginx/include.d/customhtml.conf;

  # services
{{range .Services}}
  location /{{.Name}} {
    proxy_pass {{.URL}};
  }
{{end}}
  # end of services

{{end}}
}
