#!/bin/bash

echo "Metabase setup requires a domain name. If you do not have one yet, you may"
echo "cancel this setup, press Ctrl+C. This script will run again on your next login"
echo "--------------------------------------------------"
echo "Enter the domain name for your new Metabase site."
echo "(ex. metabase.analogpond.com) do not include www or http/s"
echo "Before doing this, be sure that you have pointed your domain or subdomain to this server's IP address."
echo "--------------------------------------------------"

a=0
while [ $a -eq 0 ]
do
 read -p "Domain/Subdomain name: " dom
 if [ -z "$dom" ]
 then
  a=0
  echo "Please provide a valid domain or subdomain name to continue to press Ctrl+C to cancel"
 else
  a=1
fi
done

export dom=$dom
envsubst < /etc/nginx/sites-available/metabase | tee /etc/nginx/sites-available/metabase
nginx -t
systemctl reload nginx

echo -en "\n\n\n"
echo "Next, you have the option of configuring LetsEncrypt to secure your new site. You can also run LetsEncrypt certbot later with the command 'certbot --nginx -d example.com'"
echo -en "\n\n\n"
 read -p "Would you like to use LetsEncrypt (certbot) to configure SSL (HTTPS) for your new site? (y/n): " yn
    case $yn in
        [Yy]* ) certbot --nginx -d $dom; echo "Metabase has been enabled at https://$dom  Please open this URL in a browser to complete the setup of your site.";break;;
        [Nn]* ) echo "Skipping LetsEncrypt certificate generation";break;;
        * ) echo "Please answer y or n.";;
    esac

echo "Setup complete :D"

