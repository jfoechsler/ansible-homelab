# ansible-homelab virt-host-router example

* DNSmasq VM used as DHCP server.
* External gateway with IP 192.168.0.1 set by Dnsmasq DHCP

**group_vars/vm_hosts/vms.yml**
```yaml
vms:
  - name: router-1
    # Set hostname from user-data instead of dhcp
    static_hostname: true
    # Set static IP
    static_ip: 192.168.0.2/24
    inventory_groups:
      - vm_routers
    state: running
    image: f39
    host: myserver
    disk: 10
    admin_network: true
    bridge_network: true
    delete_on_termination: false
```
## DHCP

* For DHCP we create a scope of .50 to .150.
* For mac reservations we use from `lan_ip_start` to `lan_ip_end`.
* For VMs we use from `vm_ip_start` to `vm_ip_end`.

```yaml
lan_ip_start: 5
lan_ip_end: 50
vm_ip_start: 151
vm_ip_end: 254
```

**group_vars/vm_routers/main.yml**
```yaml
# DHCP clients DNS and IP reservation
dhcp_reservations:
  lan_hosts:
    - name: wlan-ap-1
      mac: 'b8:..'
    - name: switch-1
      mac: 'd8:..'

# Local network bridge interface
inside_nic: eth1
router_features:
  dhcpd:
    enabled: true
    # Use this IP for default gateway, bot DNSmasq itself.
    router: 192.168.0.1

firewalld:
  enabled: true
  zones:
    - name: internal
      interface: "{{ inside_nic }}"
      service_allow:
        - 'dns'
        - 'dhcp'
      service_remove: []

network:
  # We disable resolved on router and use directly DNSmasq instead
  network_manager_resolved_disable: true
  # Disable NetworkManager auto profiles for interfaces
  no_auto_default:
    - eth0
    - "{{ inside_nic }}"
  dns_servers:
    - '192.168.0.2'
    - '1.1.1.1'
    - '8.8.8.8'
  connections:
    - id: internal
      interface_name: "{{ inside_nic }}"
      zone: internal
      ipv4:
        # Use static IP set via inventory variable
        static_ip: true
    - id: cloud-init eth0
      file: cloud-init-eth0
      # Don't tear down interface used by Ansible
      suppress_reload: true
      interface_name: eth0
      ipv4:
        # Don't use routes from libvirt DNSmasq
        ignore_auto_routes: true
```

# Setup

## Set up VM router
```
ansible-playbook -i inventories/home.yaml routers.yml -K
```

## Set up any other VMs including DHCP lease on router
```
ansible-playbook -i inventories/home.yaml vms.yml -K
```
