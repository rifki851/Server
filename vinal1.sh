#!/bin/bash

# Update repository
cat > /etc/apt/sources.list2 <<EOF
#deb http://deb.debian.org/debian bookworm main contrib
#deb http://deb.debian.org/debian bookworm-updates main contrib
#deb http://security.debian.org bookworm-security main contrib

deb http://repo.ugm.ac.id/debian/ bookworm main contrib
deb http://repo.ugm.ac.id/debian/ bookworm-updates main contrib

deb http://repo.ugm.ac.id/debian/ bullseye main contrib
EOF

apt update
apt upgrade -y
echo "update repository selesai"

# Install webmin
download_url="http://10.10.2.99/webmin_2.202_all.deb"
wget "$download_url"
dpkg -i webmin_2.202_all.deb
apt install -f -y
apt install -y apache2 mariadb-server php php-mysql
echo "install webmin selesai"

# Install netdata
apt install -y netdata
cat > /etc/netdata/netdata.conf <<EOF
[global]
        run as user = netdata
        web files owner = root
        web files group = root
        # Netdata is not designed to be exposed to potentially hostile
        # networks. See https://github.com/netdata/netdata/issues/164
        bind socket to IP = 0.0.0.0
EOF
systemctl restart netdata
echo "install Netdata selesai"

# Install WordPress
wget -O /var/www/html/wordpress12.zip http://10.10.2.99/wordpress-6.7.2-id_ID.zip
cd /var/www/html
unzip wordpress12.zip
rm wordpress12.zip

# Set ownership and permissions for WordPress
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Konfigurasi Apache agar IP langsung menuju folder WordPress
cat > /etc/apache2/sites-available/000-default.conf <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/wordpress

    <Directory /var/www/html/wordpress>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Aktifkan mod_rewrite untuk WordPress
a2enmod rewrite

# Membuat database dan user untuk WordPress
mysql -e "CREATE DATABASE wpdb DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'wp_password';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'wpuser'@'localhost' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

# Buat wp-config.php otomatis
cat > /var/www/html/wordpress/wp-config.php <<EOF
<?php
define( 'DB_NAME', 'wpdb' );
define( 'DB_USER', 'wpuser' );
define( 'DB_PASSWORD', 'wp_password' );
define( 'DB_HOST', 'localhost' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

\$table_prefix = 'wp_';

define( 'WP_DEBUG', false );

/* That's all, stop editing! Happy publishing. */
if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
EOF

# Restart layanan Apache dan MariaDB
systemctl restart apache2
systemctl restart mariadb

echo "WordPress berhasil diunduh, dikonfigurasi, dan dapat diakses via http://10.10.2.214 tanpa '/wordpress'"
