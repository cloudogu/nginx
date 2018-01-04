{{ if .Config.Exists "trackingID" }}

set $analytics '<!-- Global site tag (gtag.js) - Google Analytics --> <script async src="https://www.googletagmanager.com/gtag/js?id={{ .Config.Get "trackingID" }}"></script> <script>   window.dataLayer = window.dataLayer || [];   function gtag(){dataLayer.push(arguments);}   gtag("js", new Date());   gtag("config", "{{ .Config.Get "trackingID" }}"); </script></body>';

# apply analytics script only on GET or POST requests
set $allowed_method 0;
if ($request_method = GET){
	set $allowed_method 1;
}
if ($request_method = POST){
	set $allowed_method 1;
}
if ($allowed_method != 1){
	set $analytics '</body>';
}

# do not apply analytics script on ajax requests
if ($http_x_requested_with ~ XMLHttpRequest) {
	set $analytics '</body>';
}

# replace </body> with $analytics for html pages
sub_filter '</body>' $analytics;
#sub_filter_once on;

{{ end }}
