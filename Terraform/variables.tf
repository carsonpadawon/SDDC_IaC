# this section defines the variable for the SDDC creation
variable "sddc" {
  type = map(string)
  default = {
    "name"            = "IaC Deployment"
    "region"          = "us-west-2"
    "vpc_cidr"        = "10.10.16.0/20"
    "vxlan_subnet"    = "172.30.16.0/24"
    "public_ip_name"  = "public_VM_IP"
    "number_of_hosts" = "1"
    "instance_type"   = "I3_METAL"
    "sddc_type"       = "1NODE"
    "deployment_type" = "SingleAZ"
    "provider"        = "ZEROCLOUD"
  }
}

variable "aws_acct" {
  default = "xxxxxxxxxxxx"
}