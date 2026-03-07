# Name static interfaces
/interface ethernet
set [ find default-name=ether1 ] name=interfaceToDocker
set [ find default-name=ether2 ] name=interfaceToIsp
set [ find default-name=ether3 ] name=interfaceToClient

# Enable neighbour discovery on the tunnels
/ip neighbor discovery-settings
set discover-interface-list=dynamic

# Add DNS server for spoke resolution in the tunnels
/ip dns
set allow-remote-requests=yes

# Add the bridge to host the tunnels
/interface bridge
add name=interfaceBridge priority=0x4000 vlan-filtering=yes

# Assign the tunnels to the bridge with a horizon to prevent client-to-client communication
/interface bridge port
add bridge=interfaceBridge interface=dynamic horizon=1

# Add the client interface without a horizon to permit management
add bridge=interfaceBridge interface=interfaceToClient

# Define the pool for the tunnels' DHCP server
/ip pool
add name=ipPoolBridge ranges=172.31.254.16-172.31.255.239

# Create the DHCP pool for the tunnels
/ip dhcp-server
add address-pool=ipPoolBridge interface=interfaceBridge name=ipDhcpServerBridge

# Define the tunnel network in the DHCP server with the hub as the DHCP server
/ip dhcp-server network
add address=172.31.254.0/23 dns-server=172.31.254.1

# Configure the L2TPv3 pseudowire server and assign clients to the bridge inteface list
/interface l2tp-server server
set accept-proto-version=l2tpv3 accept-pseudowire-type=ether enabled=yes one-session-per-host=yes l2tpv3-ether-interface-list=interfaceListSpokes

# Receive neighbour discovery from the spokes, but do not advertise to them
/ip neighbor discovery-settings
set discover-interface-list=dynamic mode=rx-only

# Remove CHR DHCP client
/ip dhcp-client
remove [find]

# Add static addresses
/ip address
add address=203.0.113.1/31 interface=interfaceToIsp
add address=172.31.254.1/23 interface=interfaceBridge network=172.31.254.0

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

# Add neighbour discovery to DNS script
/system script
add dont-require-permissions=no name=neighbourDiscoveryToDns owner=admin policy=read,write source=":local bridgeInterface \"interfaceBridge\"\
    \n\
    \n/ip/dns/static\
    \n:foreach neighbourRecord in=[find where comment=\"neighbourDiscoveryToDns\"] do={\
    \n  :local neighbourRecordName [get \$neighbourRecord name]\
    \n  :local neighbourId [/ip/neighbor/find where identity=\$neighbourRecordName]\
    \n  :if ([:len \$neighbourId] = 0) do={\
    \n    :log info (\"Removing stale DNS record: \$neighbourRecordName\")\
    \n    remove \$neighbourRecord\
    \n  }\
    \n}\
    \n\
    \n/ip/neighbor\
    \n:foreach neighbourDiscovery in=[find where interface~\"\$bridgeInterface\" and address4~\"^172.31.25[45]\"] do={\
    \n  :local neighbourEntry [get \$neighbourDiscovery]\
    \n  :local neighbourAddress (\$neighbourEntry->\"address4\")\
    \n  :local neighbourIdentity (\$neighbourEntry->\"identity\")\
    \n  /ip/dns/static\
    \n  :local neighbourRecord [find where name=\"\$neighbourIdentity\" and comment=\"neighbourDiscoveryToDns\"]\
    \n  :if ([:len \$neighbourRecord]>0) do={\
    \n    :local neighbourRecordEntry [get (\$neighbourRecord->0)]\
    \n    :local neighbourRecordName (\$neighbourRecordEntry->\"name\")\
    \n    :local neighbourRecordAddress (\$neighbourRecordEntry->\"address\")\
    \n    :if ([:tostr \$neighbourAddress]!=[:tostr \$neighbourRecordAddress]) do={\
    \n      :log info (\"Updating DNS record: \$neighbourRecordName from \$neighbourRecordAddress to \$neighbourAddress\")\
    \n      set (\$neighbourRecordEntry->\".id\") address=\"\$neighbourAddress\"\
    \n    }\
    \n  } else={\
    \n    :log info (\"Adding DNS record: \$neighbourIdentity \$neighbourAddress\")\
    \n    add name=\$neighbourIdentity address=\$neighbourAddress type=A comment=\"neighbourDiscoveryToDns\"\
    \n  }\
    \n}"

# Schedule neighbour discovery to DNS synchronization every five minutes
/system scheduler
add interval=5m name=neighbourDiscoveryToDns on-event="/system script run neighbourDiscoveryToDns" policy=read,write start-date=1970-01-01 start-time=00:00:00
