# ansible-homelab
Manage your home Fedora server using DNSmasq, KVM VMs, LVM, podman containers, Virtiofs

If you would like to manage your local network and services in Git all without any prerequisite services, private cloud, docker-engine/swarm or other container orchestration.

# VM and container definitions
VMs and containers can be defined without any Ansible config writing required, just using lists defined in yaml:
```
# States:
# running, shutdown, destroyed

vms:
  - name: staging1
    hostname: vm-staging1
    inventory_groups:
      - staging_vms
    state: running
    image: f36
    host: myserver
    disk: 10
    network: host-bridge
    delete_on_termination: true
    serial: 1

  - name: vm1
    state: running
    image: f36
    host: myserver
    disk: 50
    network: host-bridge
    delete_on_termination: false
    serial: 1

# States:
# present, absent
containers:
  - name: pihole-staging
    host: staging1
    image: docker.io/pihole/pihole:2022.05
    ports:
      - 3053:53/tcp
      - 3053:53/udp
      - 3080:80/tcp
    volumes:
      - path: /etc/pihole
        type: vmfs
        name: pihole-etc-staging
      - path: /etc/dnsmasq.d
        type: vmfs
        name: pihole-dnsmasq-staging
    state: present
    environment:
      TZ: 'Europe/Copenhagen'
      DNSMASQ_LISTENING: 'all'
      WEB_GID: '999'
    #dnsmasq_conf: "dnsmasq-pihole"

  - name: pihole
    host: vm1
    image: docker.io/pihole/pihole:2022.05
    ports:
      - 3053:53/tcp
      - 3053:53/udp
      - 3080:80/tcp
    volumes:
      - path: /etc/pihole
        type: vmfs
        name: pihole-etc
      - path: /etc/dnsmasq.d
        type: vmfs
        name: pihole-dnsmasq
    state: present
    environment:
      TZ: 'Europe/Copenhagen'
      DNSMASQ_LISTENING: 'all'
      WEB_GID: '999'
    dnsmasq_conf: "dnsmasq-pihole"
```
# Setup up from scratch

Need one server with Fedora installed:

* Sudo user with password login over SSH, or run Ansible from server.

## Bridge internal network interface (example enp5s0)
```
nmcli con add type bridge ifname br0 bridge.stp no
nmcli con modify bridge-br0 ipv4.method manual ipv4.addr "192.168.2.2/24"
nmcli con add type ethernet ifname enp5s0 master bridge-br0
nmcli con down enp5s0; nmcli con up bridge-br0; nmcli con up bridge-slave-enp5s0
nmcli con modify enp5s0 autoconnect 0
nmcli con modify bridge-br0 connection.zone internal
```
## External interface (enp6s0)
```
nmcli con modify enp6s0 connection.id external
nmcli con modify external connection.zone external
```

## Forwarding traffic (Not currently supported in Ansible firewalld)
```
firewall-cmd --permanent --new-policy policy_int_to_ext
firewall-cmd --permanent --policy policy_int_to_ext --add-ingress-zone internal
firewall-cmd --permanent --policy policy_int_to_ext --add-egress-zone external
firewall-cmd --permanent --policy policy_int_to_ext --set-priority 100
firewall-cmd --permanent --policy policy_int_to_ext --set-target ACCEPT
```

# First playbook runs

* Adjust home lab group vars with your personal information.
* Adjust inventory with network interface and IP details.

## Set up router (Dnsmasq/firewall) with --user option to add SSH key
```
ansible-playbook -i hosts routers.yml -k --user <username>
```
## Set up server
```
ansible-playbook -i hosts servers.yml -K
```
## Set up VM hosting
```
ansible-playbook -i hosts vm-hosts.yml -K
```
## Set up VM guests
```
ansible-playbook -i hosts vms.yml -K
```
## Set up containers
```
ansible-playbook -i hosts container-hosts.yml -K
```
