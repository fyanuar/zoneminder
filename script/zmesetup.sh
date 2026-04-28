#!/bin/bash

apt-get update && apt-get -y install wget git sudo
apt-get -y install make libprotocol-websocket-perl libyaml-perl python3-requests python3-shapely python3-dateparser python3-imageio python3-imageio-ffmpeg python3-joblib python3-pil python3-portalocker python3-progressbar2 python3-psutil python3-dateutil python3-dotenv python3-python-utils python3-pytz python3-regex python3-sklearn python3-scipy python3-six python3-threadpoolctl python3-typing-extensions python3-tzlocal python3-websocket python3-click

git clone https://github.com/ZoneMinder/zmeventnotification.git
cd zmeventnotification
PREFIX=/opt/zmeventnotification
TARGET_CONFIG=$PREFIX/etc/zm
TARGET_DATA=$PREFIX/var/lib/zmeventnotification
TARGET_BIN_ES=$PREFIX/usr/bin
TARGET_BIN_HOOK=$PREFIX/var/lib/zmeventnotification/bin
mkdir -p $PREFIX $TARGET_CONFIG $TARGET_DATA $TARGET_BIN_ES $TARGET_BIN_HOOK
yes "" | TARGET_CONFIG=$TARGET_CONFIG TARGET_DATA=$TARGET_DATA TARGET_BIN_ES=$TARGET_BIN_ES TARGET_BIN_HOOK=$TARGET_BIN_HOOK ./install.sh --install-es --install-hook --install-config

# Install python deps
pip install --root=/opt/imutils imutils
pip install --root=/opt/pyzm "pyzm<0.4.0"
pip install --root=/opt/zmes_hook_helpers hook/
pip install --root=/opt/face_recognition --no-warn-script-location --root-user-action=ignore face_recognition

# Install Net::WebSocket::Server
PERL_MM_OPT="DESTDIR=/opt/perl" cpan Net::WebSocket::Server
mv /opt/perl/usr/local/man /opt/perl/usr/local/share/

