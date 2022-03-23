warp:
  sources:
    - path: /dogu
      type: dogus
      tag: warp
    - path: /config/nginx/externals
      type: externals
  target: /var/www/html/warp/menu.json
  order:
      Development Apps: 100
  support:
      - identifier: docsCloudoguComUrl
        external: true
        href: https://docs.cloudogu.com/
      - identifier: aboutCloudoguToken
        external: false
        href: /info/about
      - identifier: myCloudogu
        external: true
        href: https://my.cloudogu.com/

service:
  source:
    path: /services
  target: /etc/nginx/conf.d/app.conf
  template: /etc/ces-confd/templates/app.conf.tpl
  maintenance-mode: /config/_global/maintenance
  tag: webapp
  pre-command: "/usr/sbin/nginx -t -c /etc/nginx/nginx.conf"
  post-command: "/usr/sbin/nginx -s reload -c /etc/nginx/nginx.conf"
  ignore-health: {{ .Config.GetOrDefault "ignore_service_health" "false" }}

maintenance:
  source:
    path: /config/_global/maintenance
  default:
    title: Maintenance
    text: The EcoSystem is currently in maintenance mode
  target: /var/www/html/errors/503.html
  template: /etc/ces-confd/templates/maintenance.html.tpl
  