## Custom Scripts

This directory contains optional custom scripts that can be activated. To do so move a certain script into the `conf.d` Volume of the Nginx (`/var/lib/ces/nginx/volumes/app.conf.d`). Then you need to restart the dogu for the script/s to apply.

### Script: block_jenkins_user_view

THis scripts blocks all member views of the Jenkins dogu. This is especially helpful for giving public access to one Jenkins instance while securing the member information.  

### Script: clear-cookies-on-logout.conf

This script ensures that all browser cookies and cached data are cleared when users log out via CAS.  
It helps prevent session reuse or automatic re-authentication after logout.
