##!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "### setting hostname"
hostname vagrant.local
if [ -z `grep -Fl vagrant.local /etc/hosts` ]; then
    echo >>/etc/hosts
    echo "192.158.40.40 vagrant.local" >>/etc/hosts
fi

echo "### Fixing dns entries"
sed -i -e"s/domain-name-servers, //g" /etc/dhcp/dhclient.conf
if [ -z `grep -Fl 8.8.8.8 /etc/dhcp/dhclient.conf` ]; then
    echo >>/etc/dhcp/dhclient.conf
    echo "prepend domain-name-servers 8.8.8.8,8.8.4.4;" >>/etc/dhcp/dhclient.conf
fi
(dhclient -r && dhclient eth0)


  echo "### Configuring Apache"
  APACHE_CONFIG='
  <VirtualHost *:80>
    DocumentRoot "/srv/www/"
    ServerName vagrant.local
    SetEnv APPLICATION_ENV "development"
    #ErrorLog "/srv/www/v2/data/logs/error_log"
    #CustomLog "/srv/www/v2/data/logs/access_log" common
    <Directory /srv/www/>
      AllowOverride All
      Options Indexes FollowSymLinks
      Order allow,deny
      Allow from all
    </Directory>
  </VirtualHost>
  '
  echo "${APACHE_CONFIG}" >/etc/apache2/sites-enabled/000-default
  a2enmod rewrite
  service apache2 restart

  echo "### Bootstrap completed"
