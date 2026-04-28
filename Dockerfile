FROM debian:stable-slim AS builder
WORKDIR /tmp
COPY script/setup.sh .
COPY cambozola.jar /usr/share/zoneminder/www/
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y --no-install-recommends dist-upgrade && apt-get -y --no-install-recommends install zoneminder apache2 libapache2-mod-php ssl-cert ffmpeg libdatetime-perl

FROM builder AS zmesbuilder
COPY script/zmesetup.sh .
RUN ./zmesetup.sh

FROM builder AS zmes
COPY --from=zmesbuilder /opt /opt/
ENTRYPOINT ["./setup.sh"]
