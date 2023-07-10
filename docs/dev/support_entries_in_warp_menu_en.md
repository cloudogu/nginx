# Configure support entries for the warp menu

The warp-menu generates the entries in the menu via a so-called menu.json. 
This is built in the ces-confd. In this the dynamic dogu entries and the support entries are contained. 
The support entries can be changed via the configuration.yaml.tpl in this repository.

If entries in the warp-menu should not be rendered the etcd key `/config/_global/disabled_warpmenu_support_entries` can be provided with a list of keys which will not be rendered.

For example, if the following entries are specified in the configuration.yaml under the key `support`:
```
warp:
  ...
  support:
    - identifier: docsCloudoguComUrl
      external: true
      href: https://path/to/extern/site.com
    - identifier: aboutCloudoguToken
      external: false
      href: /pfad/to/intern/site
    - identifier: platform
      external: true
      href: https://path/to/extern/site.com
```

and the first two should NOT be displayed than you can set the etcd-key to sth. like:
`etcdctl set /config/_global/disabled_warpmenu_support_entries '["docsCloudoguComUrl", "aboutCloudoguToken"]'`.
