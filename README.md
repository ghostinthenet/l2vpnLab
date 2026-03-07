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

Run with ./build.sh to create winbox:<em>latest_version</em> and tag it as winbox:latest.

Prerequisites:
* curl, unzip

Variables:
* CT_USER User (defaults to "admin")
* CT_PASSWD Password (defaults to $CT_USER)

Once running, it can be used from any machine with an X11 server:

ssh -J <em>containerlab</em> -X $CT_USER@<em>containername</em>

Start remote WinBox with the provided shell script.

~$ ./winbox.sh
