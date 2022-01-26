#!/bin/bash

# non-interactive install
export DEBIAN_FRONTEND=noninteractive
export UCF_FORCE_CONFFNEW=YES
export APT_LISTCHANGES_FRONTEND=none
export DPKG_FORCE=confnew

# upgrade packages
apt-get -y update
apt-get -y upgrade
apt-get -y autoremove
apt-get -y autoclean

# install openJDK
apt-get install -y default-jdk

# install certbot and NGINX
apt-GET install -y nginx certbot python3-certbot-nginx

echo "server {
    server_name $dom www.$dom;

    access_log /var/log/nginx/shiny.access.log;
    error_log /var/log/nginx/shiny.error.log;

    location / {
      proxy_pass http://localhost:3000;
      proxy_http_version 1.1;
      proxy_set_header Upgrade ;
      # proxy_set_header Connection ;
      proxy_read_timeout 20d;
    }
}" | tee /etc/nginx/sites-available/metabase

ln -s /etc/nginx/sites-available/metabase /etc/nginx/sites-enabled/metabase

# download and set permission for metabase
wget https://downloads.metabase.com/v0.41.6/metabase.jar
mkdir /opt/metabase/
mv metabase.jar /opt/metabase/metabase.jar
chmod 775 /opt/metabase/metabase.jar

# create service
printf '#!/bin/bash
java -jar /opt/metabase/metabase.jar' | tee -a /opt/metabase/metabase.sh
chmod +x /opt/metabase/metabase.sh
chmod 775 /opt/metabase/metabase.sh

printf '[Unit]
Description=Metabase

[Service]
ExecStart=/opt/metabase/metabase.sh
Restart=on-abnormal
WorkingDirectory=/opt/metabase/

[Install]
WantedBy=multi-user.target' | tee -a /etc/systemd/system/metabase.service

# activate service
systemctl enable metabase && systemctl start metabase

# open ports
ufw allow http
ufw allow https
ufw allow ssh
ufw allow 3000
ufw enable

