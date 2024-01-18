# Configuration of API Token
pveum user add {{USERNAME}}@pve
pveum group add admin -comment "Admin"
pveum acl modify / -group admin -role Administrator
pveum user modify {{USERNAME}}@pve -group admin
TOKEN=$(pveum user token add {{USERNAME}}@pve {{USERNAME}} --privsep=0 | sed -n '/│ value/s/.*│ value[[:space:]]*│[[:space:]]*\(.*\)│/\1/p')
echo "export PM_API_TOKEN_SECRET=\"${TOKEN}\"" >> ~/.bashrc
echo 'export PM_API_TOKEN_ID={{USERNAME}}@pve!{{USERNAME}}' >> ~/.bashrc

# Configuration of NAT network 
cat <<EOF | sudo tee -a /etc/network/interfaces
auto vmbr1
iface vmbr1 inet static
        address 192.168.1.1/24
        bridge-ports none
        bridge-stp off
        bridge-fd 0

        post-up echo 1 > /proc/sys/net/ipv4/ip_forward
        post-up iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o vmbr0 -j MASQUERADE
        post-down iptables -t nat -D POSTROUTING -s 192.168.1.0/24 -o vmbr0 -j MASQUERADE
EOF
ifup vmbr1

# Install and configuration of a DHCP server for the NAT Network
apt install isc-dhcp-server -y
sed -i '17s/.*/INTERFACESv4="vmbr1"/' /etc/default/isc-dhcp-server
cat <<EOL > "/etc/dhcp/dhcpd.conf"
option domain-name "example.org";
option domain-name-servers ns1.example.org, ns2.example.org;

default-lease-time 600;
max-lease-time 7200;

subnet 192.168.1.0 netmask 255.255.255.0 {
  range 192.168.1.10 192.168.1.100;
  option routers 192.168.1.1;
  option domain-name-servers 8.8.8.8;
}
EOL
service isc-dhcp-server start