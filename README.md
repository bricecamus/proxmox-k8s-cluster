# Automated kubernetes cluster deployment

Generate an ubuntu server cloud-init ready template with Packer, infrastructure deployment with Terraform and Kubernetes cluster configuration with Ansible. 


<img src="https://i.imgur.com/fFItlnc.png" width="90%" height="90%">

## Usage example

Build the packer image :
```
packer build sources.pkr.hcl
```

Deploy the infrastructure with Terraform :
```
terraform apply \
-var username="your-user" \
-var private_key_path="~/.ssh/id_rsa" \
-var public_key_path="~/.ssh/id_rsa.pub" \
-var ansible_host_ip="192.168.1.70" \
-var subnet_gw="192.168.1.1" \
-var proxmox_host_ip="192.168.1.100" \
-var storage_pool_name="local" \
-var k8s_master_ip="192.168.1.60" \
-var subnet_mask="/24" \
-parallelism=1
```
I use parallelism with value 1 to avoid the lock of the template file that happens irregularly.
