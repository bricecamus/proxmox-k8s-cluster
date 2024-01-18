# Automated kubernetes cluster deployment

Generate an ubuntu server cloud-init ready template with Packer, infrastructure deployment with Terraform and Kubernetes cluster configuration with Ansible. 


<img src="https://i.imgur.com/qdoxEgF.png" width="90%" height="90%">

## Disclaimer 

Use this repository to deploy a k8s cluster to get a TEST environnement, do not use in production as this setup is not hardened in any way and serve only as learning purpose.

## Usage example

Use the makefile to edit the variable with your desired username (used for proxmox API user and cloud-init for control-pane and nodes), desired password, the path of your ssh private key (or edit the ansible inventory file if you want to use ssh with a password), your proxmox ip and name.

You can also configure your proxmox environnement as I tested it, with a NAT setup, pre-configured DHCP server, API user for terraform, etc..

Set the variables :
```
make edit_variables USERNAME=desired-username PASSWORD=desired-password ANSIBLE_USER=your-pve-ssh-user ANSIBLE_SSH_PRIVATE_KEY_PATH=path/to/ssh/private/key PROXMOX_IP=192.168.1.100 PROXMOX_NODE_NAME=your-pve-node-name
```

Configure PVE :
```
make configure_pve
```

Build packer image, deploy K8S cluster with terraform and ansible :
```
make create_cluster
```

Delete the cluster :
```
make delete_cluster
```
