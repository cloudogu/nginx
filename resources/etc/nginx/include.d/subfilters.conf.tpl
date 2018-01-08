# warp, warp, warp
set $warp '<script type="text/javascript" async="true">(function(){var s = document.createElement("script");s.type = "text/javascript";s.async = true;s.src = "/warp/warp.js";var x = document.getElementsByTagName("script")[0];x.parentNode.insertBefore(s, x);})();</script></body>';

# apply warp menu only on GET or POST requests
set $allowed_method 0;
if ($request_method = GET){
	set $allowed_method 1;
}
if ($request_method = POST){
	set $allowed_method 1;
}
if ($allowed_method != 1){
	set $warp '</body>';
}

# do not apply warp menu on ajax requests
if ($http_x_requested_with ~ XMLHttpRequest) {
	set $warp '</body>';
}

# Include google analytics scripts if a tracking id is set
{{ if .Config.Exists "googleTrackingID" }}
if ($allowed_method = 1){
	set $analytics '<!-- Global site tag (gtag.js) - Google Analytics --> <script async src="https://www.googletagmanager.com/gtag/js?id={{ .Config.Get "googleTrackingID" }}"></script> <script>   window.dataLayer = window.dataLayer || [];   function gtag(){dataLayer.push(arguments);}   gtag("js", new Date());   gtag("config", "{{ .Config.Get "googleTrackingID" }}"); </script>';
	set $warp '$analytics $warp';
}
{{ end }}

# replace </body> with $warp for html pages
sub_filter '</body>' $warp;
sub_filter_once on;

# warp menu
location /warp {
	root /var/www/html;
}
