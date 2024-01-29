# Configure support entries for the warp menu

The warp-menu generates the entries in the menu via a so-called menu.json.
This is created in the ces-confd. This contains the dynamic dogu entries and the support entries.
The support entries can be changed via the configuration.yaml.tpl in this repository.

The support entries in the resulting configuration.yaml are given the key `support` and could look like this:

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

## Hide all entries
If all support entries of the warp-menu are not to be displayed, this can be configured via the etcd key `/config/_global/block_warpmenu_support_category`.
```shell
# hide all entries
etcdctl set /config/_global/block_warpmenu_support_category true

# do not hide any entries
etcdctl set /config/_global/block_warpmenu_support_category false
```

## Show only individual entries
If all support entries of the warp-menu are hidden, but individual entries should still be displayed, this can be configured via the etcd key `/config/_global/allowed_warpmenu_support_entries`.
A JSON array with the entries to be displayed must be specified there.

```shell
etcdctl set /config/_global/allowed_warpmenu_support_entries '["platform", "aboutCloudoguToken"]'
```

> This configuration is only effective if **all** entries are hidden (see [above](#hide-all-entries)).

## Hide individual entries
If individual entries in the warp-menu are not to be rendered, this can be configured via the etcd key `/config/_global/disabled_warpmenu_support_entries`.
A JSON array with the entries to be hidden must be specified there.

```shell
etcdctl set /config/_global/disabled_warpmenu_support_entries '["docsCloudoguComUrl", "aboutCloudoguToken"]'
```

> This configuration is only effective if **not** all entries are hidden (see [above](#hide-all-entries)).