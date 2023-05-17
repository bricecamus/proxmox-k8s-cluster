variable "proxmox_api_url" {
    type    = string
    default = "" 
}

variable "proxmox_api_token_id" {
    type    = string
    default = ""
}

variable "proxmox_api_token_secret" {
    type      = string
    default   = ""
    sensitive = true
}

source "proxmox-iso" "ubuntu-server-focal" {
    username    = "${var.proxmox_api_token_id}"
    token       = "${var.proxmox_api_token_secret}"
    proxmox_url = "${var.proxmox_api_url}"
    node        = "proxmox"

    vm_name          = "template-ubuntu-22.04"
    memory           = "2048" 
    cores            = "1"
    scsi_controller  = "virtio-scsi-pci"
    iso_file         = "local:iso/ubuntu-22.04.2-live-server-amd64.iso"
    iso_storage_pool = "local" 
    qemu_agent       = true
    unmount_iso      = true
    
    ssh_username         = ""
    ssh_private_key_file = ""
    ssh_timeout          = "20m"

    cloud_init               = true
    cloud_init_storage_pool  = "local"
    insecure_skip_tls_verify = true
    
    boot_wait = "5s"
    http_directory = "http" 
    
    disks {
        disk_size         = "20G"
        format            = "qcow2"
        storage_pool      = "local"
        storage_pool_type = "lvm"
        type              = "virtio"
    }

    network_adapters {
        model    = "e1000"
        bridge   = "vmbr1"
        firewall = "false"
    } 
    
    # You must have an ip address assigned by a dhcp server in order to use autoinstall
    boot_command = [
        "c<wait>",
        "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"",
        "<enter><wait><wait>",
        "initrd /casper/initrd",
        "<enter><wait><wait>",
        "boot",
        "<enter>"
    ]
}

build {
    name    = "template-ubuntu-22.04"
    sources = ["source.proxmox-iso.ubuntu-server-focal"]

    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo sync"
        ]
    }

    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }
}