# Name static interfaces
/interface ethernet
set [ find default-name=ether1 ] name=interfaceToDocker
set [ find default-name=ether2 ] name=interfaceToIsp
set [ find default-name=ether3 ] name=interfaceToClient

# Remove CHR DHCP client
/ip dhcp-client
remove [find]

# Add static addresses
/ip address
add address=203.0.113.1/31 interface=interfaceToIsp

# Add default route
/ip route
add gateway=203.0.113.0

# Disable unnecessary services
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
