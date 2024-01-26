# Support-Einträge für das Warp-Menü konfigurieren

Das warp-menu generiert die Einträge im Menü über eine sogenannte menu.json.
Diese wird in der ces-confd erstellt. In dieser sind die dynamischen dogu-Einträge und die Support-Einträge enthalten.
Die Supporteinträge können über die configuration.yaml.tpl in diesem Repository geändert werden.

Die Support-Einträge in der resultierenden configuration.yaml sind dem Schlüssel `support` angegeben und könnten wie folgt aussehen:

```yaml
warp:
  #...
  support:
    - identifier: docsCloudoguComUrl
      external: true
      href: https://docs.cloudogu.com/
    - identifier: aboutCloudoguToken
      external: false
      href: /info/about
    - identifier: platform
      external: true
      href: https://platform.cloudogu.com
```

## Alle Einträge ausblenden
Wenn alle Support-Einträge des warp-menu nicht angezeigt werden sollen, kann dies über den etcd-Schlüssel `/config/_global/block_warpmenu_support_category` konfiguriert werden.
```shell
# alle Einträge ausblenden
etcdctl set /config/_global/block_warpmenu_support_category true

# keine Einträge ausblenden
etcdctl set /config/_global/block_warpmenu_support_category false
```

## Nur einzelne Einträge anzeigen 
Wenn alle Support-Einträge des warp-menu ausgeblendet sind, aber trotzen einzelne davon angezeigt werden sollen, kann dies über den etcd-Schlüssel `/config/_global/allowed_warpmenu_support_entries` konfiguriert werden.
Dort muss ein JSON-Array, mit den anzuzeigenden Einträgen angegeben werden. 
```shell
etcdctl set /config/_global/allowed_warpmenu_support_entries '["platform", "aboutCloudoguToken"]'
```

> Diese Konfiguration ist nur wirksam, wenn **alle** Einträge ausgeblendet sind (siehe [oben](#alle-einträge-ausblenden)).

## Einzelne Einträge ausblenden
Wenn einzelne Einträge im warp-menu nicht gerendert werden sollen, kann dies über den etcd-Schlüssel `/config/_global/disabled_warpmenu_support_entries` konfiguriert werden.
Dort muss ein JSON-Array, mit den auszublendenden Einträgen angegeben werden.

```shell
etcdctl set /config/_global/disabled_warpmenu_support_entries '["docsCloudoguComUrl", "aboutCloudoguToken"]'
```

> Diese Konfiguration ist nur wirksam, wenn **nicht** alle Einträge ausgeblendet sind (siehe [oben](#alle-einträge-ausblenden)).