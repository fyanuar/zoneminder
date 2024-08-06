FROM debian:latest
WORKDIR /tmp
COPY script .
COPY cambozola.jar /usr/share/zoneminder/www/
RUN apt-get update && apt-get dist-upgrade && apt-get -y install zoneminder &&\
 /etc/init.d/mariadb start &&\
 mysql -e "CREATE DATABASE zm;" &&\
 mysql -e "CREATE USER zmuser@localhost IDENTIFIED BY 'zmpass';" &&\
 mysql -e "GRANT ALL ON zm.* TO zmuser@localhost;" &&\
 mysql -e "FLUSH PRIVILEGES;" &&\
 mysql -uzmuser -pzmpass zm < /usr/share/zoneminder/db/zm_create.sql &&\
 usermod -a -G video www-data &&\
 apt-get clean
ENTRYPOINT ["./setup.sh"]
