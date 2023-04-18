terraform {
  required_providers {
    vsphere = {
        source = "hashicorp/vsphere"
        version = "2.3.1"
    }
  }
}
variable "vmc_vCenter_url" {
  type = string 
  description = "value from main module output."
}
variable "vmc_vCenter_username" {
  type = string 
  description = "value from main module output."
}
variable "vmc_vCenter_password" {
  type = string 
  description = "value from main module output."
}

provider "vsphere" {
    user                    = var.vmc_vCenter_username
    password                = var.vmc_vCenter_password
    vsphere_server          = var.vmc_vCenter_url
    allow_unverified_ssl    = true
}

data "vsphere_datacenter" "vmc_datacenter" {
  name = "SDDC-Datacenter"
}

data "vsphere_resource_pool" "Compute-ResourcePool" {
  name = "Compute-ResourcePool"
  datacenter_id = data.vsphere_datacenter.vmc_datacenter.id
}

data "vsphere_datastore" "datastore" {
  name          = "WorkloadDatastore"
  datacenter_id = data.vsphere_datacenter.vmc_datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "Cluster-1"
  datacenter_id = data.vsphere_datacenter.vmc_datacenter.id
}

data "vsphere_network" "network" {
  name          = "vm_network"
  datacenter_id = data.vsphere_datacenter.vmc_datacenter.id
}

# This section creates an empty VM called Jumpbox
resource "vsphere_virtual_machine" "Jumpbox" {
  name             = "Jumpbox"
  resource_pool_id = data.vsphere_resource_pool.Compute-ResourcePool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = 2
  memory           = 2048
  guest_id         = "other3xLinux64Guest"
  network_interface {
    network_id = data.vsphere_network.network.id
  }
  disk {
    label = "disk0"
    size  = 40
  }
}

# This section creates a VM clone from an existing VM template
data "vsphere_virtual_machine" "template" {
  name          = "VM_Template_Name"
  datacenter_id = data.vsphere_datacenter.vmc_datacenter.id 
}

resource "vsphere_virtual_machine" "Demo" {
  name             = "Demo"
  resource_pool_id = data.vsphere_resource_pool.Compute-ResourcePool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = 2
  memory           = 2048
  guest_id         = "other3xLinux64Guest"
  network_interface {
    network_id     = data.vsphere_network.network.id
    adapter_type   = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }
}
