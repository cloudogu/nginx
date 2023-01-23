# Aufsetzen der Integrations Tests

Die Integration Tests, welche sich unter integrationTests/ befinden, können wie folgt ausgeführt werden:

Um die Tests lokal auszuführen muss vorher die statische HTML Seite im vagrant hinterlegt werden.
`sudo cp /vagrant/containers/nginx/integrationTests/privacy_policies.html /var/lib/ces/nginx/volumes/customhtml/`
Außerdem muss der etcd Key `privacy_policies` gesetzt werden

`etcdctl set config/nginx/externals/privacy_policies '{"DisplayName":"Privacy Policies","Description":"Contains information about the privacy policies enforced by our company","Category":"Information","URL":"/static/privacy_policies.html"}'`

Anschließend muss noch der Key zum Entfernen bestimmter Links aus dem Warp-Menü gesetzt werden:
`etcdctl set /config/_global/disabled_warpmenu_support_entries '["myCloudogu", "aboutCloudoguToken"]'`

Danach können die Tests mit:
```bash
cd integrationTests
yarn install
yarn cypress open
```
ausgeführt werden.
