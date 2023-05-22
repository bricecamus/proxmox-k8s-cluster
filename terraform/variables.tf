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
  description = "IP address of your Ansible VM (IPv4/CIDR format ex: 192.168.0.70/24)"
}

variable "proxmox_host_ip" {
  type        = string
  description = "IP address of your Proxmox host (ex: 192.168.0.10)"
}

variable "storage_pool_name" {
  type        = string
  description = "Name of the storage pool you want to use to store the VM disk"
}

variable "subnet_gw" {
  type        = string
  description = "IP address of your subnet gateway (ex: 192.168.0.1)"
}