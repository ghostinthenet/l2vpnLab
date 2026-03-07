# Establish configuration variables
:local connectTo "hub.lab.tishco.ca"
:local systemId [/system/identity/get name]

# Name static interfaces
/interface ethernet
set [ find default-name=ether1 ] name=interfaceToDocker
set [ find default-name=ether2 ] name=interfaceToIsp
set [ find default-name=ether3 ] name=interfaceToSwitch

# Add L2TPv3 pseudowire interface as interfaceToHub
/interface l2tp-ether
add connect-to="$connectTo" disabled=no l2tp-proto-version=l2tpv3-ip name=interfaceToHub

# Use ISP router's DNS server for hub resolution
/ip dns
set servers=203.0.113.128

# Change DHCP client interface to interfaceHub
/ip dhcp-client
set 0 add-default-route=no use-peer-dns=no use-peer-ntp=no interface=interfaceToHub

# Add static IPv4 addresses
/ip address
add interface=interfaceToIsp address="100.64.3.1/31"

# Add default route
/ip route
add gateway="100.64.3.0"

# Disable unnecessary services
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes

# Enable RoMON
/tool romon
set enabled=yes
