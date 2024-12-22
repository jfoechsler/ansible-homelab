# ansible-homelab example

* DNSmasq VM used as DNS and DHCP server.
* External gateway with IP 192.168.0.1 set on clients by Dnsmasq DHCP.
* Pihole DNS is provided to clients via DHCP.
* Virtiofs used to store VM data on host.
* Fedora updates stored in local repository.
