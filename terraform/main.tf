resource "proxmox_vm_qemu" "c1-cp1" {
    name                      = "c1-cp1"
    boot                      = "order=virtio0"
    clone                     = "template-ubuntu-22.04"
    target_node               = var.pve_node_name
    scsihw                    = "virtio-scsi-pci"
    cpu                       = "host"
    agent                     = 1
    sockets                   = 1
    cores                     = 2
    memory                    = 3072
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
        size      = "100G"
        iothread  = 0
    }
}

resource "proxmox_vm_qemu" "c1-workers" {
    count                     = 2
    name                      = "c1-node${count.index+1}"
    boot                      = "order=virtio0"
    clone                     = "template-ubuntu-22.04"
    target_node               = var.pve_node_name
    scsihw                    = "virtio-scsi-pci"
    cpu                       = "host"
    agent                     = 1
    sockets                   = 1
    cores                     = 2
    memory                    = 3072
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
        size      = "100G"
        iothread  = 0 
    }

    depends_on = [ proxmox_vm_qemu.c1-cp1 ]
}

resource "local_file" "ansible_inventory" {
    content = templatefile("../ansible/inventory.tftpl",
        {
            master_ip = proxmox_vm_qemu.c1-cp1.default_ipv4_address
            worker_ip = proxmox_vm_qemu.c1-workers[*].default_ipv4_address
        }
    )

    filename = "../ansible/inventory"
    depends_on = [ proxmox_vm_qemu.c1-workers, proxmox_vm_qemu.c1-cp1 ]
}

resource "local_file" "ansible_config" {
    content = templatefile("../ansible/ansible.cfg.tftpl",
        {
            username = var.username
        }
    )

    filename = "../ansible/ansible.cfg"
    depends_on = [ proxmox_vm_qemu.c1-workers, proxmox_vm_qemu.c1-cp1 ]
}


resource "proxmox_vm_qemu" "c1-ansible" {
    name                      = "c1-ansible"
    boot                      = "order=virtio0"
    clone                     = "template-ubuntu-22.04"
    target_node               = var.pve_node_name
    scsihw                    = "virtio-scsi-pci"
    cpu                       = "host"
    agent                     = 1
    sockets                   = 1
    cores                     = 2
    memory                    = 3072
    ci_wait                   = 0
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
        size      = "100G"
        iothread  = 0
    }

    connection {
        type        = "ssh"
        host        = var.ansible_host_ip
        user        = var.username
        password    = var.username
        private_key = file(var.private_key_path)    
    }

    provisioner "local-exec" {
        command = "scp -qo StrictHostKeyChecking=no -i ${var.private_key_path} ${var.private_key_path} ${var.username}@${var.ansible_host_ip}:/home/${var.username}/.ssh"
    }

    provisioner "local-exec" {
        command = "scp -qo StrictHostKeyChecking=no -i ${var.private_key_path} -r ../ansible ${var.username}@${var.ansible_host_ip}:/home/${var.username}"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo chmod 0600 /home/${var.username}/.ssh/id_rsa",
            "sudo apt-add-repository ppa:ansible/ansible -y",
            "sudo apt update",
            "nohup sudo apt install ansible -y",
            "sudo mkdir /etc/ansible",
            "sudo cp /home/${var.username}/ansible/ansible.cfg /etc/ansible",
            "ansible-playbook /home/${var.username}/ansible/playbook.yml -i /home/${var.username}/ansible/inventory",
        ]
        on_failure = continue
    }

    depends_on = [ local_file.ansible_config, local_file.ansible_inventory ]
}
