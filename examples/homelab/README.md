# ansible-homelab example

# Description

* LVM group used for VMs.
* DNSmasq VM used as DNS and DHCP server.
* External gateway with IP 192.168.0.1 set on clients by Dnsmasq DHCP.
* Pihole DNS is provided to clients via DHCP.
* Virtiofs used to store VM data on host.
* Fedora updates stored in local repository.

# Setup

* Edit inventory file.
  * Add vm_hosts host.
* Edit group vars.
  * Adjust to suit needs.
  * Adjust vm host hostname to match inventory.
* Run playbook to install required packages:
 ```shell
ansible-playbook -i inventories/home.yml --diff -K myserver.yml 
```
* Run playbook to install required packages on server:
 ```shell
ansible-playbook -i inventories/home.yml --diff -K myserver.yml 
```
* Run playbooks to bootstrap Dnsmasq VM:
 ```shell
ansible-playbook -i inventories/home.yml --diff -K vms.yml -e vm_filter=gateway-1
ansible-playbook -i inventories/home.yml --diff -K routers.yml
```
* Run playbooks to create VMs:
 ```shell
ansible-playbook -i inventories/home.yml --diff -K vms.yml
```
* Run playbooks to create containers:
 ```shell
ansible-playbook -i inventories/home.yml --diff -K containers.yml
```
