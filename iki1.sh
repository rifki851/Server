#!/bin/bash
cat > /etc/apt/sources.list2 <<EOF
#deb http://deb.debian.org/debian bookworm main contrib
#deb http://deb.debian.org/debian bookworm-updates main contrib
#deb http://security.debian.org bookworm-security main contrib

deb http://repo.ugm.ac.id/debian/ bookworm main contrib
deb http://repo.ugm.ac.id/debian/ bookworm-updates main contrib

deb http://repo.ugm.ac.id/debian/ bullseye main contrib
EOF

apt update
apt upgrade
echo "update repository selesai"

#install webmin
wget https://raw.githubusercontent.com/rifki851/Server/refs/heads/main/webmin.deb
dpkg -i webmin.deb
apt install -f
apt install apache2 mariadb-server php
echo "install webmin selesai"

#install netdata
apt install netdata
cat > /etc/netdata/netdata.conf <<EOF
# NetData Configuration
# The current full configuration can be retrieved from the running
# server at the URL
#
#   http://localhost:19999/netdata.conf
#
# for example:
#
#   wget -O /etc/netdata/netdata.conf http://localhost:19999/netdata.conf
#

[global]
        run as user = netdata
        web files owner = root
        web files group = root
        # Netdata is not designed to be exposed to potentially hostile
        # networks. See https://github.com/netdata/netdata/issues/164
        bind socket to IP = 0.0.0.0
EOF

systemctl restart netdata
echo "install Netdata selesai "

#install wordpress
apt install php-mysql
systemctl restart apache2
echo "Mysql berhasil active>> "

TARGET_DIR="/var/www/html"
ZIP_FILE="wordpress12.zip"

wget -O "$TARGET_DIR/$ZIP_FILE" "https://raw.githubusercontent.com/rifki851/Server/refs/heads/main/wordpress12.zip"
cd "$TARGET_DIR"
unzip "$ZIP_FILE"
cd wordpress12.zi
mv wordpress /var/www/html/
rm "$ZIP_FILE"

chown -R www-data:www-data "$TARGET_DIR"
chmod -R 755 "$TARGET_DIR"

systemctl status mysql
echo "WordPress berhasil diunduh dan diekstrak di $TARGET_DIR"
