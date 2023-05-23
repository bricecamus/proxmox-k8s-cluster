variable "username" {
  type        = string
  description = "Your linux session username"
}

variable "private_key_path" {
  type        = string
  description = "Path to your private key (ex: /home/your-user/.ssh/id_rsa)"
}

variable "public_key_path" {
  type        = string
  description = "Path to your public key (ex: /home/your-user/.ssh/id_rsa.pub)"
}

variable "ansible_host_ip" {
  type        = string
  description = "IP address of your Ansible VM (ex: 192.168.0.70)"
}

variable "proxmox_host_ip" {
  type        = string
  description = "IP address of your Proxmox host (ex: 192.168.0.10)"
}

variable "k8s_master_ip" {
  type        = string
  description = "IP address you want for your kubernetes master (ex: 192.168.0.60)"
}

variable "storage_pool_name" {
  type        = string
  description = "Name of the storage pool you want to use to store the VM disk"
}

variable "subnet_gw" {
  type        = string
  description = "IP address of your subnet gateway (ex: 192.168.0.1)"
}

variable "subnet_mask" {
  type        = string
  description = "Subnet mask you want to use in CIDR format (ex: /24)"
}