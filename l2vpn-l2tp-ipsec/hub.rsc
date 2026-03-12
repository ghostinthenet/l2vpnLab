# Name static interfaces
/interface ethernet
set [ find default-name=ether1 ] name=interfaceToDocker
set [ find default-name=ether2 ] name=interfaceToIsp
set [ find default-name=ether3 ] name=interfaceToClient

# Add DNS server for spoke resolution in the tunnels
/ip dns
set allow-remote-requests=yes

# Add the bridge to host the tunnels
/interface bridge
add name=interfaceBridge vlan-filtering=yes

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

# Configure the L2TPv3 pseudowire server
/interface l2tp-server server
set accept-proto-version=l2tpv3 accept-pseudowire-type=ether enabled=yes one-session-per-host=yes

# Receive neighbour discovery from the spokes, but do not advertise to them
/ip neighbor discovery-settings
set mode=rx-only

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

# Import certificate authority certificate
/file
add name=ca.crt type=file contents="-----BEGIN CERTIFICATE-----\n
MIIFjzCCA3egAwIBAgIUeutgq+6Z+s3eq16XUZjPPPfoHPcwDQYJKoZIhvcNAQEL\n
BQAwXjELMAkGA1UEBhMCQ0ExEDAOBgNVBAgMB09udGFyaW8xFjAUBgNVBAcMDU5p\n
YWdhcmEgRmFsbHMxGDAWBgNVBAoMD3Rpc2hjbyBuZXR3b3JrczELMAkGA1UEAwwC\n
Y2EwHhcNMjYwMTEwMTQyMzU2WhcNNDYwMTEwMTQyMzU2WjBeMQswCQYDVQQGEwJD\n
QTEQMA4GA1UECAwHT250YXJpbzEWMBQGA1UEBwwNTmlhZ2FyYSBGYWxsczEYMBYG\n
A1UECgwPdGlzaGNvIG5ldHdvcmtzMQswCQYDVQQDDAJjYTCCAiIwDQYJKoZIhvcN\n
AQEBBQADggIPADCCAgoCggIBAL41MzvANfsP6kxID0MIL/iEh6vEd8a3S0GkPIHX\n
hZCvTg65pKEvJJP6TpPzgFhJOkIdKFuuS37D2qyMd/3Gbzb1KFUgyU65I0I23n4K\n
jKm02zYb8iH46nnsydtpf/bVVeFqZ0Xrs4KEHu+Qd37tApa12ryqA6x3PqhKCYQn\n
Usa08tVxpNHzPalqY1VEttzVscBRq5UcpCFe3OTHxCXmI5f2Dfbg0jJMNI4nptzh\n
APBP2+9jpidFi5JMUdSH6iL5IjUq7b0dnf9z+dK8eU6po4FCj9TUSbal7qFIbmpe\n
RXCwboe7J/ElbHlPlnphZdQIAOMi3N18erhT39GV1avGbPPD8+9WE41KukCZZ9Nb\n
AuVkho0Z0swXfUT9sMVVMCH3T5c2ibKDrhjjvnqAYkFL2ptJ3Zsw5lu+XHnEzkli\n
WOea5+6tDAG5Q14fw42H08UL1B3pqRwRgzBB4F9C8trILl1oDCgIS17YdlI2Qpb8\n
5KqdJnLcYDXhqNgehZSDAm6iMRSGKeWdMrW5cBu9fl5cszF22x9FhQqsoxVKCUYw\n
zo27x5KCufhgnveEyK7AglbL62SUDE141v8R979N7xGXNyctfgZfoZ3r3T0/mYWY\n
ko23HJsobJd6sYtgyhBG9Fdj72DoxR1JDUgDEqOxI31qt69GuIlLkxG+FIs4nnEY\n
TOXfAgMBAAGjRTBDMBIGA1UdEwEB/wQIMAYBAf8CAQEwDgYDVR0PAQH/BAQDAgEG\n
MB0GA1UdDgQWBBTDA209XR7MysWr7a7zeyj7/XUoPjANBgkqhkiG9w0BAQsFAAOC\n
AgEARB3A5VwREdaI593FkXD2iGnWxa+bzqXpU/b2C0A6l9sZ8XAY9flDPX362yKn\n
5M1ceWp4LPtvAwxjhial1yzSvQV9PM8ZwZIdYdY7H63XYYzDTb9TczV0/4ZjO44g\n
6GTSeE0TEawD/AR7mZMS3qEM4lgKV3AN3LS+NVHa1oy6QzLlHB2mUwhhIMSSWykL\n
hiFDJCDVrobCwMNHa64surSDGAqu6RMJUO7OfQXaeqobR3Q2EhOMR1zCxi8UgVsh\n
eAgCBl7H86tgSumAyZMfOh1dW2/47fPPEzvKVrJHPwggL0YhMqPYuUOjVE8Rl9mM\n
5I7mtDPffZclxw/drY93G2ZVZq82WJHwuT93lPbWdF7DSWWtUiSJI2zeJefgk4YF\n
yZTxuIxd9/MQPpj2BWW0kA828+xInJE55d8LSMPvI+Tej9yurfovy4hrehWi0K0Q\n
mv+MXskDAuUEQQSI12G9aUo0uP/SYjj/ZEiP4G8MN+MtRAC8cZiiUjkuVpH9hEwi\n
rUpFZI9IcCh++1MZKYDqGaC624Cuup4OsGSUG0Llm42SQA8xk7KwlB5sJPN3ETKQ\n
Ajoz4ryC/upbBlyaApMQKyTvCDBWQYy9+RE7efBX4Z9cqCIpG3l16FmsxY30JFAl\n
xEAm7O12FvkUwVacbDm7NMXzQ3aV4SMR9UXSgFluZ2SNZPE=\n
-----END CERTIFICATE-----"

# Import hub certificate
add name=hub.crt type=file contents="-----BEGIN CERTIFICATE-----\n
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\n
hsukbqYbENhn00rlqTnDvyFDjg==\n
-----END CERTIFICATE-----"

# Import hub private key
add name=hub.key type=file contents="-----BEGIN PRIVATE KEY-----\n
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\n
gThoXrJWrlIKYC4YxcmyZrLbglpcsg==\n
-----END PRIVATE KEY-----"

# Import certificates and keys
/certificate
import

# Rename certificates and keys according to common name (CN)
:foreach counter=entry in=[find] do={set $entry name=[get $entry common-name]}

# Enable the user manager and set it to use the hub certificate and key
/user-manager
set certificate=hub enabled=yes

# Allow localhost to authenticate against User Manager
/user-manager router
add address=::1 name=localhost shared-secret=localhost

# Add spoke routers and passwords to User Manager for EAP authentication
/user-manager user
add name=spoke1 password=spoke1
add name=spoke2 password=spoke2
add name=spoke3 password=spoke3
add name=spoke4 password=spoke4

# Configure router to use User Manager for authentication
/radius
add address=::1 secret=localhost

# Add IKEv2/IPSec passive peer for tunnel encryption
/ip ipsec peer
add exchange-mode=ike2 name=ipsecPeerDynamic passive=yes send-initial-contact=no

# Configure spokes to use EAP against User Manager for identity and authentication
/ip ipsec identity
add auth-method=eap-radius certificate=hub generate-policy=port-strict peer=ipsecPeerDynamic
