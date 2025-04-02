#!/bin/bash

# Unduh dan instal OpenVPN
wget https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x openvpn-install.sh
./openvpn-install.sh

# Tambahkan repository ke sources.list dengan benar
cat >> /etc/apt/sources.list <<EOF
deb http://kartolo.sby.datautama.net.id/debian/ bullseye main
EOF

# Perbarui sistem dan instal Asterisk
apt update
apt install -y asterisk asterisk-dahdi

# Konfigurasi SIP untuk Asterisk
cat > /etc/asterisk/sip.conf <<EOF
[general]
context=default
videosupport=yes

[114]
context=tjkt
type=friend
secret=123
host=dynamic

[214]
context=tjkt
type=friend
secret=123
host=dynamic
EOF

# Konfigurasi extensions.conf untuk dial plan
cat > /etc/asterisk/extensions.conf <<EOF
[tjkt]
exten => 114,1,Dial(SIP/114)
exten => 114,n,Hangup()

exten => 214,1,Dial(SIP/214)
exten => 214,n,Hangup()
EOF

# Restart Asterisk dan cek status
systemctl restart asterisk
systemctl status asterisk