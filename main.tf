
provider "vsphere" {
  vsphere_server = "192.168.20.202"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

/*resource "vsphere_folder" "folder" {
  path          = "ceph"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}
*/
data "vsphere_datacenter" "dc" {
  name = "DatacenterLM"
}

data "vsphere_datastore" "datastore" {
  name          = "Datastore"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "Pool1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "PG_VL30"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "ubuntu16"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_distributed_virtual_switch" "dvs" {
  name          = "DSTrunk"
  datacenter_id = data.vsphere_datacenter.dc.id
}



//https://computingforgeeks.com/how-to-deploy-ceph-storage-cluster-on-ubuntu-18-04-lts/
resource "vsphere_virtual_machine" "mon" {
  name             = "kube16-ceph-mon${count.index}"
  count = 3
  nested_hv_enabled = true
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder = "ceph"
  num_cpus = 2
  memory   = 8192
  guest_id = "ubuntu64Guest"

  connection {
    type = "ssh"
    user = "root"
    private_key = file("~/.ssh/id_rsa")
    host = self.default_ip_address
  }
provisioner "remote-exec" {
    scripts = [
      "create_users.sh"
    ]
  }

provisioner "file" {
    content = file("~/.ssh/id_rsa.pub")
    destination = "/home/ceph-admin/.ssh/authorized_keys"
}

provisioner "file" {
    content = file("~/.ssh/id_rsa.pub")
    destination = "/home/ceph-admin/.ssh/id_rsa.pub"
}

provisioner "file" {
    content = file("~/.ssh/id_rsa")
    destination = "/home/ceph-admin/.ssh/id_rsa"
}

clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    linked_clone = true
    customize {
      linux_options {
        host_name = "mon0${count.index+1}"
        domain    = "test.internal"
      }

      network_interface {
      }

    }
}

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = 32
  }
}

resource "vsphere_virtual_machine" "osd" {
  name             = "kube16-ceph-osd${count.index}"
  count = 3
  nested_hv_enabled = true
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder = "ceph"
  num_cpus = 2
  memory   = 8192
  guest_id = "ubuntu64Guest"
  connection {
    type = "ssh"
    user = "root"
    private_key = file("~/.ssh/id_rsa")
    host = self.default_ip_address
  }
provisioner "remote-exec" {
    scripts = [
      "create_users.sh"
    ]
  }

provisioner "file" {
    content = file("~/.ssh/id_rsa.pub")
    destination = "/home/ceph-admin/.ssh/authorized_keys"
}

provisioner "file" {
    content = file("~/.ssh/id_rsa.pub")
    destination = "/home/ceph-admin/.ssh/id_rsa.pub"
}

provisioner "file" {
    content = file("~/.ssh/id_rsa")
    destination = "/home/ceph-admin/.ssh/id_rsa"
}


clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    linked_clone = true
    customize {
      linux_options {
        host_name = "osd0${count.index+1}"
        domain    = "test.internal"
      }

      network_interface {
      }

    }
}

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = 32
  }
}

resource "vsphere_virtual_machine" "rgw" {
  name             = "kube16-ceph-rgw"
  nested_hv_enabled = true
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder = "ceph"
  num_cpus = 2
  memory   = 8192
  guest_id = "ubuntu64Guest"

  connection {
    type = "ssh"
    user = "root"
    private_key = file("~/.ssh/id_rsa")
    host = self.default_ip_address
  }
  provisioner "remote-exec" {
    scripts = [
      "create_users.sh"
    ]
  }

provisioner "file" {
    content = file("~/.ssh/id_rsa.pub")
    destination = "/home/ceph-admin/.ssh/authorized_keys"
}

provisioner "file" {
    content = file("~/.ssh/id_rsa.pub")
    destination = "/home/ceph-admin/.ssh/id_rsa.pub"
}

provisioner "file" {
    content = file("~/.ssh/id_rsa")
    destination = "/home/ceph-admin/.ssh/id_rsa"
}

clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    linked_clone = true
    customize {
      linux_options {
        host_name = "rgw"
        domain    = "test.internal"
      }

      network_interface {
      }

    }
}

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = 32
  }
}
resource "vsphere_virtual_machine" "admin" {
  name             = "kube16-ceph-admin"
  nested_hv_enabled = true
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder = "ceph"
  num_cpus = 2
  memory   = 4096
  guest_id = "ubuntu64Guest"

  connection {
    type = "ssh"
    user = "root"
    private_key = file("~/.ssh/id_rsa")
    host = self.default_ip_address
  }

  
provisioner "remote-exec" {
    scripts = [
      "list_files.sh"
    ]
  }
provisioner "remote-exec" {
    inline = [
      "echo \"${vsphere_virtual_machine.rgw.default_ip_address}  rgw\" >> /etc/hosts",
      "echo \"${vsphere_virtual_machine.osd[0].default_ip_address}  osd01\" >> /etc/hosts",
      "echo \"${vsphere_virtual_machine.osd[1].default_ip_address}  osd02\" >> /etc/hosts",
      "echo \"${vsphere_virtual_machine.osd[2].default_ip_address}  osd03\" >> /etc/hosts",
      "echo \"${vsphere_virtual_machine.mon[0].default_ip_address}  mon01\" >> /etc/hosts",
      "echo \"${vsphere_virtual_machine.mon[1].default_ip_address}  mon02\" >> /etc/hosts",
      "echo \"${vsphere_virtual_machine.mon[2].default_ip_address}  mon03\" >> /etc/hosts",
    ]
  }

provisioner "file" {
    content = file("~/.ssh/id_rsa.pub")
    destination = "/home/ceph-admin/.ssh/authorized_keys"
}

provisioner "file" {
    content = file("~/.ssh/id_rsa.pub")
    destination = "/home/ceph-admin/.ssh/id_rsa.pub"
}

provisioner "file" {
    content = file("~/.ssh/id_rsa")
    destination = "/home/ceph-admin/.ssh/id_rsa"
}
provisioner "file" {
    content = file("ssh_config")
    destination = "/home/ceph-admin/.ssh/config"
}

clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    linked_clone = true
    customize {
      linux_options {
        host_name = "ceph-admin"
        domain    = "test.internal"
      }

      network_interface {
      }

    }
}

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = 32
  }
}