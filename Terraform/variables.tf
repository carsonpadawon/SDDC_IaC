/* this secection defines your API token
and the org_id */

variable "security" {
  type = map(string)
  default = {
    "api_token" = var.r_token
    "org_id"    = var.org_id
  }
}

# this section defines the variable for the SDDC creation
variable "sddc" {
  type = map(string)
  default = {
    "name"            = "TKGm"
    "region"          = "us-west-2"
    "vpc_cidr"        = "10.10.16.0/20"
    "vxlan_subnet"    = "172.30.16.0/24"
    "public_ip_name"  = "TKGm_public_IP"
    "number_of_hosts" = "1"
    "instance_type"   = "I3_METAL"
    "sddc_type"       = "1NODE"
    "deployment_type" = "SingleAZ"
    "provider"        = "AWS"
  }
}

variable "aws_acct" {
  default = "683684961168"
}