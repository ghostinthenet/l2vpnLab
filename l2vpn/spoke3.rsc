# Establish configuration variables
:local connectTo "hub.lab.tishco.ca"
:local systemId [/system/identity/get name]

# Name static interfaces
/interface ethernet
set [ find default-name=ether1 ] name=interfaceToDocker
set [ find default-name=ether2 ] name=interfaceToIsp
set [ find default-name=ether3 ] name=interfaceToSwitch

# Use ISP router's DNS server
/ip dns
set servers=203.0.113.128

# Add static addresses
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
