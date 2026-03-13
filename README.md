# l2vpnLab
L2VPN (L2TPv3 Pseudowire / IPsec) lab for MTPC 2026.

## l2vpn
Contains the base lab image including:

* Underlay addressing
* DNS resolution for hub.lab.tishco.ca on the ISP router

## l2vpn-l2tp
Contains the L2TPv3 pseudowire lab image adding the following to the base image:

* L2TPv3 pseudowires
* Bridge with the client interface and horizoned L2TPv3 pseudowires
* DHCP server for the Bridge interface
* Receive-only neighbour discovery on dynamic connections
* Script and five minute scheduler to transpose discovered hosts to static DNS entries (not in presentation)

## l2vpn-l2tp-ipsec
Contains the IKEv2/IPsec L2TPv3 pseudowire lab, which adds:

* Certificate-based IKEv2/IPsec transport for L2TPv3-IP
* EAP-TTLS authentication for spoke devices
* Basic firewall preventing non-encrypted L2TPv3-IP connections

# Docker Images

## mikrotik_routeros

Base RouterOS images and full (including all optional packages) are used in these labs. They are built using vrnetlab according to the instructions here:

[MikroTik Cloud Hosted Router Images in ContainerLab](https://ghostinthenet.info/chr-in-containerlab/)

## client
Creates Debian 13 based ContainerLab Docker image for WinBox.

Run the build script to create winbox:<em>latest_version</em> and tag it as winbox:latest.

<pre>./build.sh</pre>

Prerequisites:
* curl, unzip

Variables:
* CT_USER User (defaults to "admin")
* CT_PASSWD Password (defaults to $CT_USER)

Once running, it can be used from any machine with an X11 server:

<pre>ssh -J <em>containerlab</em> -X <em>$CT_USER</em>@<em>containername</em></pre>

Start remote WinBox with the provided shell script.

<pre>./winbox.sh</pre>

# l2vpn-certs
Zsh scripts to generate new certificates, keys and RouterOS import scripts for IPsec transports and EAP-TTLS authentication. Pre-generated certificates, keys, and import scripts for the lab have also been included. 

Prerequisites:

* openssl, sed

Generate the CA certificate and key with ca-generate.sh:

<pre>./ca-generate.sh <em>ca-name</em></pre>

Generate the hub certificate with generate.sh:

<pre>./generate <em>ca-name</em> hub</pre>

Export the certificates into RouterOS import scripts:

<pre>./routeros-import.sh <em>ca</em> hub
./routeros-import.sh <em>ca</em> spokes</pre>

Once created, the scripts can be copied to the router and imported:

<pre>/import file-name=<em>import-file</em></pre>

These can also be added to netinstall scripts to ensure that routers have what's necessary to connect to the management VPN in the event of a reset.
