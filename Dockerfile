FROM debian:stable-slim
WORKDIR /tmp
COPY script .
COPY cambozola.jar /usr/share/zoneminder/www/
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get --no-install-recommends dist-upgrade && apt-get -y --no-install-recommends install zoneminder apache2 libapache2-mod-php ssl-cert ffmpeg
ENTRYPOINT ["./setup.sh"]
