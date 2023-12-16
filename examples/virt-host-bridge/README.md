# ansible-homelab virt-host-bridge example

* Extends virt-host example.
* VM will be on the local network via bridge interface.

**group_vars/vm_hosts/main.yml**
```yaml
network_bridge_name: br0
```
**group_vars/vm_hosts/vms.yml**
```yaml
vms:
  - name: test-1
    ...
    bridge_network: true
```
# Setup

* Bridge interface
```shell
nmcli con add type bridge ifname br0 bridge.stp no
nmcli con add type ethernet ifname <your interface> master bridge-br0
nmcli con down <your interface>
nmcli con up bridge-br0
nmcli con up bridge-slave-<your interface>
```
* Adjust group vars with your personal information.

## Set up server and VM
```
ansible-playbook -i inventories/home.yaml vms.yml -K
```
