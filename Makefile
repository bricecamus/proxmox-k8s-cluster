edit_variables:
	sed -i -e 's#{{PROXMOX_IP}}#$(PROXMOX_IP)#' -e 's#{{ANSIBLE_USER}}#$(ANSIBLE_USER)#' -e 's#{{ANSIBLE_SSH_PRIVATE_KEY_PATH}}#$(ANSIBLE_SSH_PRIVATE_KEY_PATH)#' ansible/inventory/inventory.ini
	sed -i -e 's/{{USERNAME}}/$(USERNAME)/' -e 's/{{PROXMOX_NODE_NAME}}/$(PROXMOX_NODE_NAME)/' -e 's/{{PROXMOX_IP}}/$(PROXMOX_IP)/' ansible/roles/deploy-k8s-cluster/tasks/main.yml
	sed -i -e 's/{{USERNAME}}/$(USERNAME)/' -e 's/{{PROXMOX_NODE_NAME}}/$(PROXMOX_NODE_NAME)/' -e 's/{{PROXMOX_IP}}/$(PROXMOX_IP)/' ansible/roles/delete-k8s-cluster/tasks/main.yml
	sed -i -e 's/{{PROXMOX_NODE_NAME}}/$(PROXMOX_NODE_NAME)/' ansible/roles/build-packer-template/tasks/main.yml
	sed -i -e 's/{{PROXMOX_IP}}/$(PROXMOX_IP)/' packer/ubuntu-22.04-template/sources.pkr.hcl
	sed -i -e 's/{{USERNAME}}/$(USERNAME)/' scripts/configure-pve.sh
	
configure_pve:
	ansible-playbook ansible/playbooks/configure-pve.yml -i ansible/inventory/inventory.ini

create_cluster:
	ansible-playbook ansible/playbooks/setup-k8s-cluster.yml -i ansible/inventory/inventory.ini

delete_cluster:
	ansible-playbook ansible/playbooks/delete-k8s-cluster.yml -i ansible/inventory/inventory.ini