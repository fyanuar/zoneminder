#!/bin/bash

# Set timezone
if [ ! -z $TZ ]; then
  echo "Configuring Timezone..... $TZ"
  ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
  dpkg-reconfigure -f noninteractive tzdata
  PHP_VER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
  sed -i "s|;date.timezone =|date.timezone = $TZ|" /etc/php/$PHP_VER/apache2/php.ini
fi

# MySQL di local atau remote?
# Jika di local, install mariadb-server
if [[ ! ${INSTALL_DB,,} =~ ^(false|off|no|0)$ ]]; then
  apt-get -y --no-install-recommends install mariadb-server
# Letakkan konfigurasi mysql di /srv/config
  if [ -d /srv/config/mysql ]; then
    rm -rf /etc/mysql
    ln -s /srv/config/mysql /etc/
  else
    mkdir -p /srv/config/mysql
    mv /etc/mysql /srv/config/
    ln -s /srv/config/mysql /etc/
  fi
# Letakkan data mysql /srv/data
  if [ -d /srv/data/mysql ]; then
    rm -rf /var/lib/mysql
    ln -s /srv/data/mysql /var/lib/
  else
    mkdir -p /srv/data/mysql
    mv /var/lib/mysql /srv/data/
    ln -s /srv/data/mysql /var/lib/
  fi
  /etc/init.d/mariadb start
  [ -n "$DB_USER" ] || DB_USER="zmuser"
  [ -n "$DB_PASS" ] || DB_PASS="zmpass"
  mysql -e "CREATE DATABASE IF NOT EXISTS zm"
  mysql -e "CREATE USER IF NOT EXISTS $DB_USER@localhost IDENTIFIED BY \"$DB_PASS\""
  mysql -e "GRANT ALL ON zm.* TO $DB_USER@localhost;"
  mysql -e "FLUSH PRIVILEGES"

  TABLE_COUNT=$(mysql -u"$DB_USER" -p"$DB_PASS" -D zm -e "SHOW TABLES;" | wc -l)

  if [ "$TABLE_COUNT" -le 1 ]; then
      echo "Mengimpor skema database ZoneMinder..."
      mysql -u"$DB_USER" -p"$DB_PASS" zm < /usr/share/zoneminder/db/zm_create.sql
  else
      echo "Database 'zm' sudah terisi, melewati tahap impor."
  fi

#
# Jika di remote, atur konfigurasi database di zm.conf
else
  echo "Make sure the database on $DB_HOST has its credentials and privileges configured correctly."
  sleep 3
  mysql -h$DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < /usr/share/zoneminder/db/zm_create.sql
  sed -i "s|ZM_DB_HOST=localhost|ZM_DB_HOST=$DB_HOST|" /etc/zm/zm.conf
fi

# Letakkan konfigurasi zoneminder di /srv/config
if [ -d /srv/config/zm ]; then
  rm -rf /etc/zm
  ln -s /srv/config/zm /etc/
else
  mkdir -p /srv/config/zm
  mv /etc/zm /srv/config/
  ln -s /srv/config/zm /etc/
fi
# Letakkan data zoneminder di /srv/data
if [ -d /srv/data/zm ]; then
  rm -rf /var/cache/zoneminder/events
  ln -s /srv/data/zm/events /var/cache/zoneminder
else
  mkdir -p /srv/data/zm/events
  chown -R www-data:www-data /srv/data/zm
  mv /var/cache/zoneminder/events /srv/data/zm
  ln -s /srv/data/zm/events /var/cache/zoneminder
fi

# Atur zm.conf
sed -i "s|ZM_DB_USER=zmuser|ZM_DB_USER=$DB_USER|" /etc/zm/zm.conf
sed -i "s|ZM_DB_PASS=zmpass|ZM_DB_PASS=$DB_PASS|" /etc/zm/zm.conf

# Konfigurasi zm
sed -i 's|FFMPEG_EXECUTABLE-NOTFOUND|/usr/bin/ffmpeg|' /etc/zm/conf.d/01-system-paths.conf

# Apakah zoneminder multi-server?
if [ -n "$ZM_SERVER_HOST" ]; then
  echo "Setting up multi-server zoneminder....."
  sed -i "s|#ZM_SERVER_HOST=.*$|ZM_SERVER_HOST=$ZM_SERVER_HOST|" /etc/zm/conf.d/02-multiserver.conf
fi

chgrp -c www-data /etc/zm/zm.conf

# mengaktifkan url API
sed -i '28,$ d' /etc/apache2/conf-available/zoneminder.conf

cat <<EOF >> /etc/apache2/conf-available/zoneminder.conf
# For better visibility, the following directives have been migrated from the
# default .htaccess files included with the CakePHP project.
# Parameters not set here are inherited from the parent directive above.
<Directory "/usr/share/zoneminder/www/api">
   RewriteEngine on
   RewriteRule ^$ app/webroot/ [L]
   RewriteRule (.*) app/webroot/$1 [L]
   RewriteBase /zm/api
</Directory>

<Directory "/usr/share/zoneminder/www/api/app">
   RewriteEngine on
   RewriteRule ^$ webroot/ [L]
   RewriteRule (.*) webroot/$1 [L]
   RewriteBase /zm/api
</Directory>

<Directory "/usr/share/zoneminder/www/api/app/webroot">
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
    RewriteBase /zm/api
</Directory>
EOF

a2enconf zoneminder
a2enmod cgi ssl rewrite
a2ensite default-ssl.conf

/etc/init.d/apache2 start
/etc/init.d/zoneminder start
/usr/bin/zmpkg.pl stop

apt-get autopurge
apt-get dist-clean

tail -F /var/log/zm/*.log
