#Support-Einträge für das Warp-Menü konfigurieren

Das warp-menu generiert die Einträge im Menü über eine sogenannte menu.json.
Diese wird in der ces-confd erstellt. In dieser sind die dynamischen dogu-Einträge und die Support-Einträge enthalten.
Die Supporteinträge können über die configuration.yaml.tpl in diesem Repository geändert werden.

Wenn Einträge im warp-menu nicht gerendert werden sollen, kann der etcd-Schlüssel `/config/_global/disabled_warpmenu_support_entries` mit einer Liste von Schlüsseln versehen werden, die nicht gerendert werden sollen.

Zum Beispiel, wenn die folgenden Einträge in der configuration.yaml unter dem Schlüssel `support` angegeben sind:
```
warp:
  ...
  Unterstützung:
    - Bezeichner: docsCloudoguComUrl
      extern: wahr
      href: https://path/to/extern/site.com
    - Bezeichner: aboutCloudoguToken
      extern: falsch
      href: /pfad/zu/intern/site
    - Bezeichner: myCloudogu
      extern: wahr
      href: https://path/to/extern/site.com
```

und die ersten beiden sollten NICHT angezeigt werden, dann kann man den etcd-Schlüssel auf etwas wie folgt setzen:
`etcdctl set /config/_global/disabled_warpmenu_support_entries '["docsCloudoguComUrl", "aboutCloudoguToken"]'`.