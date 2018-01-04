{{ if .Config.Exists "trackingID" }}

set $analytics '</footer><!-- Global site tag (gtag.js) - Google Analytics --> <script async src="https://www.googletagmanager.com/gtag/js?id={{ .Config.Get "trackingID" }}"></script> <script>   window.dataLayer = window.dataLayer || [];   function gtag(){dataLayer.push(arguments);}   gtag("js", new Date());   gtag("config", "{{ .Config.Get "trackingID" }}"); </script>';

# apply analytics script only on GET or POST requests
set $allowed_method 0;
if ($request_method = GET){
	set $allowed_method 1;
}
if ($request_method = POST){
	set $allowed_method 1;
}
if ($allowed_method != 1){
	set $analytics '</footer>';
}

# do not apply analytics script on ajax requests
if ($http_x_requested_with ~ XMLHttpRequest) {
	set $analytics '</footer>';
}

# replace </footer> with $analytics for html pages
sub_filter '</footer>' $analytics;
#sub_filter_once on;

{{ end }}
