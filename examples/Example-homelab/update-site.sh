echo "Update Site"
echo "Staging VMs"
read staging_vms
ansible-playbook -i hosts -v update-vms.yml -K -e staging=true
echo "VMs"
read vms
ansible-playbook -i hosts -v update-vms.yml -K -e staging=false
echo "Servers"
read servers
ansible-playbook -i hosts -v update-servers.yml -K
