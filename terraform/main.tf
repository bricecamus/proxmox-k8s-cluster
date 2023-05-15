resource "proxmox_vm_qemu" "k8s-master" {
    name                      = "k8s-master"
    boot                      = "order=virtio0"
    clone                     = "template-ubuntu-22.04"
    target_node               = "proxmox"
    scsihw                    = "virtio-scsi-pci"
    cpu                       = "host"
    agent                     = 0
    sockets                   = 1
    cores                     = 2
    memory                    = 2048
    ci_wait                   = 0
    ciuser                    = ""
    cipassword                = ""
    ipconfig0                 = ""
    sshkeys                   = ""

    network {
        bridge    = "vmbr1"
        model     = "e1000"
        firewall  = false
        link_down = false
    }

    disk {
        type      = "virtio"
        storage   = "local"
        size      = "20G"
    }

    depends_on = [ proxmox_vm_qemu.ansible-master ]
}

resource "proxmox_vm_qemu" "k8s-worker-01" {
    name                      = "k8s-worker-01"
    boot                      = "order=virtio0"
    clone                     = "template-ubuntu-22.04"
    target_node               = "proxmox"
    scsihw                    = "virtio-scsi-pci"
    cpu                       = "host"
    agent                     = 0
    sockets                   = 1
    cores                     = 2
    memory                    = 2048
    ciuser                    = ""
    cipassword                = ""
    ipconfig0                 = ""
    sshkeys                   = ""
    ci_wait                   = 0

    network {
        bridge    = "vmbr1"
        model     = "e1000"
        firewall  = false
        link_down = false
    }

    disk {
        type      = "virtio"
        storage   = "local"
        size      = "20G"
    }

    depends_on = [ proxmox_vm_qemu.k8s-master ]
}

resource "proxmox_vm_qemu" "ansible-master" {
    name                      = "ansible-master"
    boot                      = "order=virtio0"
    clone                     = "template-ubuntu-22.04"
    target_node               = "proxmox"
    scsihw                    = "virtio-scsi-pci"
    cpu                       = "host"
    agent                     = 0
    sockets                   = 1
    cores                     = 2
    memory                    = 2048
    ciuser                    = ""
    cipassword                = ""
    ipconfig0                 = ""
    sshkeys                   = ""

    network {
        bridge    = "vmbr1"
        model     = "e1000"
        firewall  = false
        link_down = false
    }

    disk {
        type      = "virtio"
        storage   = "local"
        size      = "20G"
    }

    connection {
        type        = "ssh"
        host        = ""
        user        = ""
        private_key = file("")    
    }

    provisioner "file" {
        source      = ""
        destination = ""
    }

    provisioner "file" {
        source      = ""
        destination = ""
    }

    provisioner "remote-exec" {
        inline = [
            "sudo chmod 0600 <path-to-ssh>",
            "sudo apt-add-repository ppa:ansible/ansible -y",
            "sudo apt update",
            "nohup sudo apt install ansible -y"
        ]
    }
}