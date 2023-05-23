resource "proxmox_vm_qemu" "k8s-master" {
    name                      = "k8s-master-01"
    boot                      = "order=virtio0"
    clone                     = "template-ubuntu-22.04"
    target_node               = "proxmox"
    scsihw                    = "virtio-scsi-pci"
    cpu                       = "host"
    agent                     = 1
    sockets                   = 1
    cores                     = 2
    memory                    = 2048
    ci_wait                   = 0
    ciuser                    = var.username
    cipassword                = var.username
    ipconfig0                 = "ip=${var.k8s_master_ip}${var.subnet_mask},gw=${var.subnet_gw}"
    sshkeys                   = file(var.public_key_path)

    network {
        bridge    = "vmbr1"
        model     = "e1000"
        firewall  = false
        link_down = false
    }

    disk {
        type      = "virtio"
        storage   = var.storage_pool_name
        size      = "20G"
        iothread  = 0
    }
}

resource "proxmox_vm_qemu" "k8s-workers" {
    count                     = 2
    name                      = "k8s-worker-0${count.index+1}"
    boot                      = "order=virtio0"
    clone                     = "template-ubuntu-22.04"
    target_node               = "proxmox"
    scsihw                    = "virtio-scsi-pci"
    cpu                       = "host"
    agent                     = 1
    sockets                   = 1
    cores                     = 2
    memory                    = 2048
    ci_wait                   = 0
    ciuser                    = var.username
    cipassword                = var.username
    ipconfig0                 = "ip=192.168.1.${count.index+10}${var.subnet_mask},gw=${var.subnet_gw}"
    sshkeys                   = file(var.public_key_path)

    network {
        bridge    = "vmbr1"
        model     = "e1000"
        firewall  = false
        link_down = false
    }

    disk {
        type      = "virtio"
        storage   = var.storage_pool_name
        size      = "20G"
        iothread  = 0 
    }

    depends_on = [ proxmox_vm_qemu.k8s-master ]
}

resource "local_file" "ansible_inventory" {
    content = templatefile("../ansible/inventory.tftpl",
        {
            master_ip = proxmox_vm_qemu.k8s-master.default_ipv4_address
            worker_ip = proxmox_vm_qemu.k8s-workers[*].default_ipv4_address
        }
    )
    filename = "../ansible/inventory"

    depends_on = [ proxmox_vm_qemu.k8s-workers]
}

resource "local_file" "ansible_config" {
    content = templatefile("../ansible/ansible.cfg.tftpl",
        {
            username = var.username
        }
    )
    filename = "../ansible/ansible.cfg"

    depends_on = [ proxmox_vm_qemu.k8s-workers]
}

resource "proxmox_vm_qemu" "ansible-master" {
    name                      = "ansible-master"
    boot                      = "order=virtio0"
    clone                     = "template-ubuntu-22.04"
    target_node               = "proxmox"
    scsihw                    = "virtio-scsi-pci"
    cpu                       = "host"
    agent                     = 1
    sockets                   = 1
    cores                     = 2
    memory                    = 2048
    ciuser                    = var.username
    cipassword                = var.username
    ipconfig0                 = "ip=${var.ansible_host_ip}${var.subnet_mask},gw=${var.subnet_gw}"
    sshkeys                   = file(var.public_key_path)

    network {
        bridge    = "vmbr1"
        model     = "e1000"
        firewall  = false
        link_down = false
    }

    disk {
        type      = "virtio"
        storage   = var.storage_pool_name
        size      = "20G"
        iothread  = 0 
    }

    connection {
        type        = "ssh"
        host        = var.ansible_host_ip
        user        = var.username
        password    = var.username
        private_key = file(var.private_key_path)    
    }

    provisioner "file" {
        source      = var.private_key_path
        destination = "/home/${var.username}/.ssh/id_rsa"
    }

    provisioner "file" {
        source      = "../ansible"
        destination = "/home/${var.username}"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo chmod 0600 /home/${var.username}/.ssh/id_rsa",
            "sudo apt-add-repository ppa:ansible/ansible -y",
            "sudo apt update",
            "nohup sudo apt install ansible -y",
            "sudo mkdir /etc/ansible",
            "sudo cp /home/${var.username}/ansible/ansible.cfg /etc/ansible",
            "ansible-playbook /home/${var.username}/ansible/playbook.yml -i /home/${var.username}/ansible/inventory"
        ]

        on_failure = continue
    }

    depends_on = [ local_file.ansible_inventory, local_file.ansible_config ]
}