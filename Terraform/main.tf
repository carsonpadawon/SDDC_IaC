terraform {
  required_providers {
    vmc = {
      source  = "vmware/vmc"
      version = "1.13.0"
    }
  }
}
# These variables will be prompted for when you run PLAN or APPLY.  You can set them as ENV variables by using 
# export TF_VAR_rtoken='' && export TF_VAR_orgid='' at the CLI.data " "name".
variable "rtoken" {
  type = string
}
variable "orgid" {
  type = string
}

provider "vmc" {
  refresh_token = var.rtoken
  org_id        = var.orgid
}

data "vmc_connected_accounts" "set_aws_acct" {
  account_number = var.aws_acct
}
data "vmc_customer_subnets" "segment_172" {
  connected_account_id = data.vmc_connected_accounts.set_aws_acct.id
  region               = var.sddc.region
}

resource "vmc_sddc" "sddc_1" {
  sddc_name           = var.sddc.name
  vpc_cidr            = var.sddc.vpc_cidr
  num_host            = var.sddc.number_of_hosts
  provider_type       = var.sddc.provider
  region              = data.vmc_customer_subnets.segment_172.region
  vxlan_subnet        = var.sddc.vxlan_subnet
  delay_account_link  = true
  skip_creating_vxlan = false
  sso_domain          = "vmc.local"
  host_instance_type  = var.sddc.instance_type
  sddc_type           = var.sddc.sddc_type
  deployment_type     = var.sddc.deployment_type
  edrs_policy_type    = "cost"
  enable_edrs         = false
  lifecycle {
    ignore_changes = [edrs_policy_type,enable_edrs]
  }

  account_link_sddc_config {
    customer_subnet_ids  = [data.vmc_customer_subnets.segment_172.ids[0]]
    connected_account_id = data.vmc_connected_accounts.set_aws_acct.id
  }

  timeouts {
    create = "300m"
    update = "300m"
    delete = "180m"
  }
}
 resource "vmc_public_ip" "public_ip_1" {
  nsxt_reverse_proxy_url = vmc_sddc.sddc_1.nsxt_reverse_proxy_url
  display_name           = var.sddc.public_ip_name
}
output "nsxt_proxy_url" {
  value = trimprefix(vmc_public_ip.public_ip_1.nsxt_reverse_proxy_url, "https://")
}
output "vCenter_url" {
  value = vmc_sddc.sddc_1.vc_url
}
output "cloud_admin_username" {
  value = vmc_sddc.sddc_1.cloud_username
}
output "cloud_admin_password" {
  value = vmc_sddc.sddc_1.cloud_password
}

# Uncomment this section to run the NSXT module.  Please fill in your site specific information in the NSX module first.
/*
module "nsxt" {
  source = "./modules/nsxt"
  nsxt_proxy_url = "nsxt_proxy_url"
  vmc_api_token = var.rtoken
}
*/
# Uncomment this section to run the vSphere module.  Please fill in your site specific information in the vSphere module first.
/*
module "vsphere" {
  source = "./modules/vsphere"
  vmc_vCenter_url = "vCenter_url"
  vmc_vCenter_username = "cloud_admin_username"
  vmc_vCenter_password = "cloud_admin_password"
}
output "DemoVM_ipaddress" {
  value = module.vsphere.DemoVM_ipaddress
}
output "webinarVM_ipaddress" {
  value = module.vsphere.webinarVM_ipaddress
}
*/