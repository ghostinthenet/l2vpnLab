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

# Add static addresses
/ip address
add interface=interfaceToIsp address="203.0.113.3/31"

# Add default route
/ip route
add gateway="203.0.113.2"

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

# Import certificates and keys
/certificate
import

# Rename certificates and keys according to common name (CN)
:foreach counter=entry in=[find] do={set $entry name=[get $entry common-name]}

# Add IKEv2/IPsec peer for tunnel encryption
/ip ipsec peer
add address="$connectTo" exchange-mode=ike2 name=ipsecPeerHub

# Configure hub connection to use EAP-TTLS for identity and authentication
/ip ipsec identity
add auth-method=eap eap-methods=eap-ttls peer=ipsecPeerHub username=$systemId password=$systemId

# Add IPsec policy for L2TP-IP in transport mode
/ip ipsec policy
set 0 disabled=yes
add peer=ipsecPeerHub protocol=l2tp tunnel=no
