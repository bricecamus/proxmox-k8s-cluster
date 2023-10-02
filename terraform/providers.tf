terraform {
  required_providers {
    # Last providers update had some problems with cloud-init at this time
    # Everything stable with 2.9.11
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.9.11"	
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://${var.proxmox_host_ip}:8006/api2/json"
}
