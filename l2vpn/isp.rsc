# Name static interfaces
/interface ethernet
set [ find default-name=ether1 ] name=interfaceToDocker
set [ find default-name=ether2 ] name=interfaceToHub
set [ find default-name=ether3 ] name=interfaceToSpoke1
set [ find default-name=ether4 ] name=interfaceToSpoke2
set [ find default-name=ether5 ] name=interfaceToSpoke3
set [ find default-name=ether6 ] name=interfaceToSpoke4

# Remove CHR DHCP client
/ip dhcp-client
remove [find]

# Add static IPv4 addresses
/ip address
add interface=lo address=203.0.113.128/32
add interface=interfaceToHub address=203.0.113.0/31
add interface=interfaceToSpoke1 address=203.0.113.2/31
add interface=interfaceToSpoke2 address=203.0.113.4/31
add interface=interfaceToSpoke3 address=100.64.3.0/31
add interface=interfaceToSpoke4 address=100.64.4.0/31

# Disable neighbour discovery
/ip neighbor discovery-settings
set discover-interface-list=none

# Enable DNS server for hub resolution
/ip dns
set allow-remote-requests=yes
/ip dns static
add address=203.0.113.1 name=hub.lab.tishco.ca type=A

# Create CG-NAT interface lists
/interface list
add name=interfaceListNatSources

# Add CG-NAT sources to interfaceListNatSources
/interface list member
add interface=interfaceToSpoke3 list=interfaceListNatSources
add interface=interfaceToSpoke4 list=interfaceListNatSources

# Add CG-NAT pool for lab
/ip firewall nat
add action=src-nat chain=srcnat in-interface-list=interfaceListNatSources out-interface=interfaceToHub to-addresses=203.0.113.192/26

# Disable unnecessary services
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
