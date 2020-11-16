# Contains the configuration to deliver static html content
location /{{.Config.GetOrDefault "html_content_url" "static"}} { 
  alias /var/www/customhtml/; 
}
