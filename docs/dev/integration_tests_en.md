# Setting up the integration tests

The integration tests, which are located under integrationTests/, can be executed as follows:

To run the tests locally, the static HTML page must first be stored in vagrant.
sudo cp /vagrant/containers/nginx/integrationTests/privacy_policies.html /var/lib/ces/nginx/volumes/customhtml/`
Also the etcd key `privacy_policies` must be set

`etcdctl set config/nginx/externals/privacy_policies '{"DisplayName": "PrivacyPolicies", "Description": "Contains information about the privacy policies enforced by our company", "Category": "Information", "URL":"/static/privacy_policies.html"}'`.

After that the tests cann be run with:

```bash
cd integrationTests
yarn install
yarn cypress open
```