export interface=$(cat ./Interfacename.txt)
tar -xf dhcp-10.0.8.tar.xz
install  -v -m700 -d /var/lib/dhcpcd &&

groupadd -g 52 dhcpcd        &&
useradd  -c 'dhcpcd PrivSep' \
         -d /var/lib/dhcpcd  \
         -g dhcpcd           \
         -s /bin/false       \
         -u 52 dhcpcd &&
chown    -v dhcpcd:dhcpcd /var/lib/dhcpcd
./configure --prefix=/usr                \
            --sysconfdir=/etc            \
            --libexecdir=/usr/lib/dhcpcd \
            --dbdir=/var/lib/dhcpcd      \
            --runstatedir=/run           \
            --privsepuser=dhcpcd         &&
make
make install
cd ..
rm -r dhcpcd-10.0.8.tar.xz
cd ..
cd config
tar -xf blfs-systemd-units-20240801.tar.xz
cd blfs-systemd-units-20240801
make install-dhcpcd
systemctl start dhcpcd@$interfacename
systemctl enable dhcpcd@$interface
cd ..
rm -r blfs-systemd-units-20240801
ip link set $interface up
dhcpcd $interface