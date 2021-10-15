# warp menu
set $scripts '<script type="text/javascript">(function(){var s = document.createElement("script");s.type = "text/javascript";s.src = "/warp/warp.js";var x = document.getElementsByTagName("script")[0];console.log(x);console.log(document.getElementsByTagName("script"));x.parentNode.insertBefore(s, x);})();</script></body>';

# This header has to be removed. Otherwise it could block the warp menu
proxy_hide_header Content-Security-Policy

# Include google analytics scripts if a tracking id is set
{{ if .Config.Exists "google_tracking_id" }}
set $analytics '<script> var disableStr = "ga-disable-{{ .Config.Get "google_tracking_id" }}"; if (document.cookie.indexOf(disableStr + "=true") > -1) { window[disableStr] = true; }; function gaOptout() { document.cookie = disableStr + "=true; expires=Thu, 31 Dec 2099 23:59:59 UTC; path=/"; window[disableStr] = true; }</script><!-- Global site tag (gtag.js) - Google Analytics --> <script async src="https://www.googletagmanager.com/gtag/js?id={{ .Config.Get "google_tracking_id" }}"></script> <script>   window.dataLayer = window.dataLayer || [];   function gtag(){dataLayer.push(arguments);}   gtag("js", new Date());   gtag("config", "{{ .Config.Get "google_tracking_id" }}", { "anonymize_ip": true }); </script>﻿  <link rel="stylesheet" type="text/css" href="https://cloudogu.com/css/cookieconsent.min.css" /> <script src="https://cloudogu.com/javascripts/cookieconsent.min.js"></script> <script> window.addEventListener("load", function(){ window.cookieconsent.initialise({ "palette": { "popup": { "background": "#23a3dd", "text": "#ffffff" }, "button": { "background": "#878787", "text": "#ffffff" } }, "content": { "message": "This website uses cookies to ensure you get the best experience on our website. By continuing to use our websites, you consent to the use of cookies.", "href": "/info/privacyPolicy", "link": "Our Privacy Policy", "dismiss": "Got it!" } })}); </script> ';
set $scripts '$analytics $scripts';
{{ end }}

# apply scripts only on GET or POST requests
set $allowed_method 0;
if ($request_method = GET){
	set $allowed_method 1;
}
if ($request_method = POST){
	set $allowed_method 1;
}
if ($allowed_method != 1){
	set $scripts '</body>';
}

# do not apply warp menu on ajax requests
if ($http_x_requested_with ~ XMLHttpRequest) {
	set $scripts '</body>';
}

# replace </body> with $scripts for html pages
sub_filter '</body>' $scripts;
sub_filter_once on;

# warp menu
location /warp {
	root /var/www/html;
}
