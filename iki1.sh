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
wget 10.10.2.99/webmin_2.202_all.deb
dpkg -i webmin_2.202_all.deb
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

wget -O /var/www/html/wordpress12.zip 10.10.2.99/wordpress-6.7.2-id_ID.zip
cd /var/www/html
unzip wordpress12.zip
rm wordpress12.zip

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

systemctl restart apache2
systemctl status mysql
echo "WordPress berhasil diunduh dan diekstrak di $TARGET_DIR"
