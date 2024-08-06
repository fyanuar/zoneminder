#!/bin/bash

TZ="Asia/Jakarta"
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

if [ -d /srv/config/mysql ]; then
  rm -rf /etc/mysql
  ln -s /srv/config/mysql /etc/
else
  mkdir -p /srv/config/mysql
  mv /etc/mysql /srv/config/
  ln -s /srv/config/mysql /etc/
fi

if [ -d /srv/config/zm ]; then
  rm -rf /etc/zm
  ln -s /srv/config/zm /etc/
else
  mkdir -p /srv/config/zm
  mv /etc/zm /srv/config/
  ln -s /srv/config/zm /etc/
fi

if [ -d /srv/data/mysql ]; then
  rm -rf /var/lib/mysql
  ln -s /srv/data/mysql /var/lib/
else
  mkdir -p /srv/data/mysql
  mv /var/lib/mysql /srv/data/
  ln -s /srv/data/mysql /var/lib/
fi

if [ -d /srv/data/zm ]; then
  rm -rf /var/cache/zoneminder
  ln -s /srv/data/zm /var/cache/zoneminder
else
  mv /var/cache/zoneminder /srv/data/zm
  ln -s /srv/data/zm /var/cache/zoneminder
fi

chgrp -c www-data /etc/zm/zm.conf
a2enconf zoneminder
a2enmod cgi ssl
a2ensite default-ssl.conf
/etc/init.d/mariadb start
/etc/init.d/apache2 start
/etc/init.d/zoneminder start
tail -F /var/log/zm/*.log
