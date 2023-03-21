terraform {
  required_providers {
    vsphere = {
        source = "hashicorp/vsphere"
        version = "2.2.0"
    }
  }
}
variable "vmc_vCenter_url" {
  default = "vcenter.sddc-52-34-52-13.vmwarevmc.com"
}
variable "vmc_vCenter_username" {
  default = "cloudadmin@vmc.local"
}
variable "vmc_vCenter_password" {
  default = "W!Sw+Rat16zYCSf"
}
variable "datacenter" {
  default = "SDDC-Datacenter"
}
variable "hosts" {
  default = [
    "10.10.18.4"
  ]
}
provider "vsphere" {
    user                    = var.vmc_vCenter_username
    password                = var.vmc_vCenter_password
    vsphere_server          = var.vmc_vCenter_url
    allow_unverified_ssl    = false
}
data "vsphere_datacenter" "vmc_datacenter" {
  name = "SDDC-Datacenter"
}
data "vsphere_host" "host" {
  count         = length(var.hosts)
  name          = var.hosts[count.index]
  datacenter_id = data.vsphere_datacenter.vmc_datacenter.id
}
resource "vsphere_compute_cluster" "compute_cluster" {
  name            = "Cluster-1"
  datacenter_id   = data.vsphere_datacenter.vmc_datacenter.id
  host_system_ids = [data.vsphere_host.host.*.id]
}
data "vsphere_datastore" "vmc_workload_datastore" {
    name                    = "WorkloadDatastore"
    datacenter_id           = data.vsphere_datacenter.vmc_datacenter.name
}
resource "vsphere_content_library" "resource_library" {
  name                      = "S3 Bucket Resource Library"
  description               = "S3 Bucket Resource Library"
  storage_backing           = [data.vsphere_datastore.vmc_workload_datastore]
}