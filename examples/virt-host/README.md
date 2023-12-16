# ansible-homelab virt-host example

* Server setup with libvirt KVM and a test VM using LVM for disk.
* VM will be on the local default network only.
* An entry will be added the servers hosts file for convenience. 
* This will overwrite contents on host file with templated one  

**group_vars/all/main.yml**
```yaml
# Our local network prefix 
prefix_24: "192.168.0"
# Your public key for SSH authentication
ssh_public_key: "ssh-rsa AAAA..."
# Our home network domain
domain: "home.example.com"
# LVM volume group used for VM disk
data_vg: my_data
# Data path for storing OS images and VM configuration
# Used as mount location for main LVM data volume if LVM managed is enabled 
data0_path: /mnt/data0
```

**group_vars/vm_hosts/vms.yml**
```yaml
vm_image:
  f39: Fedora-Cloud-Base-39-1.5.x86_64.raw.xz

# States:
# created, running, shutdown, destroyed
vms:
  - name: test-1
    state: running
    image: f39
    host: myserver
    disk: 10
    admin_network: true
    delete_on_termination: true
```
# Setup

Need one server with Fedora installed:

* Sudo user with password login over SSH, or run Ansible from server.
* Ansible installed in toolbox container or on host
```shell
sudo dnf -y install \
  genisoimage \
  python3 \
  ansible \
  libxcrypt-compat \
  python3-xmltodict \
  sshpass
```
* Adjust group vars with your personal information.
* Adjust inventory with host details.

## Set up server and VM
```
ansible-playbook -i inventories/home.yaml vms.yml -K
```
