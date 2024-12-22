# ansible-homelab
Manage your Fedora home servers DNSmasq, KVM VMs, LVM, podman containers, Virtiofs etc.

Features provided:
* Declarative VM and container creation and management using libvirtd, podman and systemd.
* Dynamically adding VMs to inventory groups.
* Support configuration templating for container files, such as Nginx configuration files.
* Manage Dnsmasq based DHCP and DNS.
* Supported Dnsmasq conf.d content based on output from container templates, such as `dhcp-option` and `cname` for Pihole and Nginx proxy support.
* Manage firewalld zones, rules and policy.
* Supports enabling static DNS resolver configration instead of NetworkManager/resolved managed. 
* Manage Yum repositories to maintain a local update staging mirror.

# Setup up from scratch

Need one server with Fedora installed:

* Sudo user with private key or password login over SSH, or run Ansible from server.
* Packages installed on control host: ansible, python3-xmltodict, sshpass.

## Bridge internal network interface
For bridged VMs, we need a bridge created using our physical interface.

Example using enp5s0 device as the shared device:
```
nmcli con add type bridge ifname br0 bridge.stp no
nmcli con modify bridge-br0 ipv4.method manual ipv4.addr "192.168.0.2/24"
nmcli con add type ethernet ifname enp5s0 master bridge-br0
nmcli con down enp5s0; nmcli con up bridge-br0; nmcli con up bridge-slave-enp5s0
nmcli con modify enp5s0 autoconnect 0
```

# Network setup
The different types of network modes supported are:
1. ISP router as gateway and DHCP server. Dnsmasq added in ISP router as custom DNS. Manages VMs DHCP/DNS. 
2. ISP router as gateway only. Dnsmasq manages DHCP/DNS for VMs and other clients.
3. Fedora Dnsmasq as DNS/DHCP.
   1. as managed VM.
   2. as physical managed host.

# Getting started
See examples directory to get started.
