<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Nginx_logo.svg/1280px-Nginx_logo.svg.png" alt="nginx logo" height="100px">


[![GitHub license](https://img.shields.io/github/license/cloudogu/nginx.svg)](https://github.com/cloudogu/nginx/blob/master/LICENSE)
[![GitHub release](https://img.shields.io/github/release/cloudogu/nginx.svg)](https://github.com/cloudogu/nginx/releases)

# Nginx Dogu

## About this Dogu

**Name:** official/nginx

**Description:** [Nginx](https://en.wikipedia.org/wiki/Nginx)  is a web server which can also be used as a reverse proxy, load balancer, mail proxy and HTTP cache

**Website:** https://www.nginx.com/

**Dependencies:** [base](https://github.com/cloudogu/base)

## Installation Ecosystem
```
cesapp install official/nginx

cesapp start nginx
```

## Custom Content Page Delivery
It is possible to deliver HTML content pages via the nginx dogu and navigate to them sucessfully with the warp menu in the Cloudogu EcoSystem. In the following, we explain the necessary steps to get your HTML content accessible. For this example, we use the following simplifed HTML website:
```
<html>
   <head>
      <title>Privacy Policy</title>
   </head>
   <body>
     <h1>Private Data We Receive And Collect</h1>
    Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
   </body>
</html>
```
1) Save the HTML site as `privacy_policies.html` in the volume `/var/lib/ces/nginx/volumes/customhtml/`. Note: You can store all your HTML files in this volume. After restarting the nginx dogu the website should be accessible via `fqdn/static/privacy-policies.html`.
2) For every link we want to show in the warpmenu we need to create an etcdctl key in the form of `etcdctl /config/nginx/externals/<websitename>`. For our example page, we create the following key: `/config/nginx/externals/privacy_policies`. The value for the key needs to be a JSON object containing the following information:
```
{
   "DisplayName":"Privacy Policies", 
   "Description":"Contains information about the privacy policies enforced by our company",
   "Category":"Information",
   "URL":"/static/privacy_policies.html"
}
```
The entry `DisplayName` is the label shown in the warp menu. The `Category` is the label for the group of links. All entries of the same category are grouped together in the warp menu. The `URL` contains the relative path to your HTML file. The default url prefix is `static`. This prefix can be changed to any value with the configuration entry `/config/nginx/html_content_url`. For example, setting the configuration entry `/config/nginx/html_content_url` to `cloudogu` and changing the value of `"URL":"/static/privacy_policies.html"` to `"URL":"/cloudogu/privacy_policies.html"` makes all our HTML pages available via `fqdm/cloudogu/<websitename>`.

3) Restarting the nginx dogus is sufficent to make our sites accessible and linked in the warp menu.

### Custom Content Delivery with Blueprints
A blueprint can be helpful to group the necessary configurations that has do be done. The following blueprint contains the minimal amount of configurations to host HTML files via `fqdn/exampleprefix/<websitename.html>`:
```
{
   "blueprintApi":"v1",
   "blueprintId":"<%= @blueprint_id -%>",
   "cesappVersion":"2.20.0",
   "registryConfig":{
      "nginx":{
         "externals":{
            "privacy_policies":"{\"DisplayName\": \"Privacy Policies\",\"Description\": \"Empty\",\"Category\": \"Information\",\"URL\": \"/exampleprefix/privacy-policy.html\"}",
            "terms":"{\"DisplayName\": \"Terms & Conditions\",\"Description\": \"Empty\",\"Category\": \"Information\",\"URL\": \"/exampleprefix/terms-conditions.html\"}"
         },
         "html_content_url":"exampleprefix"
      }
   }
}
```
Put your HTML files in `/var/lib/ces/nginx/volumes/customsite/` and upgrade your ecosystem with the blueprint (`cesapp upgrade blueprint <blueprintfilename>`). The files should now be available under `fqdn/exampleprefix/privacy-policy.html`,  `fqdn/exampleprefix/terms-conditions.html`, or their respective links in the warpmenu.

---
### What is the Cloudogu EcoSystem?
The Cloudogu EcoSystem is an open platform, which lets you choose how and where your team creates great software. Each service or tool is delivered as a Dogu, a Docker container. Each Dogu can easily be integrated in your environment just by pulling it from our registry. We have a growing number of ready-to-use Dogus, e.g. SCM-Manager, Jenkins, Nexus, SonarQube, Redmine and many more. Every Dogu can be tailored to your specific needs. Take advantage of a central authentication service, a dynamic navigation, that lets you easily switch between the web UIs and a smart configuration magic, which automatically detects and responds to dependencies between Dogus. The Cloudogu EcoSystem is open source and it runs either on-premises or in the cloud. The Cloudogu EcoSystem is developed by Cloudogu GmbH under [MIT License](https://cloudogu.com/license.html).

### How to get in touch?
Want to talk to the Cloudogu team? Need help or support? There are several ways to get in touch with us:

* [Website](https://cloudogu.com)
* [myCloudogu-Forum](https://forum.cloudogu.com/topic/34?ctx=1)
* [Email hello@cloudogu.com](mailto:hello@cloudogu.com)

---
&copy; 2020 Cloudogu GmbH - MADE WITH :heart:&nbsp;FOR DEV ADDICTS. [Legal notice / Impressum](https://cloudogu.com/imprint.html)
