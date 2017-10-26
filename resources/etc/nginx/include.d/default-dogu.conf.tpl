# redirect to configured default dogu
location = / {
  return 301 https://$host/{{ .GlobalConfig.GetOrDefault "default_dogu" "cockpit" }};
}
