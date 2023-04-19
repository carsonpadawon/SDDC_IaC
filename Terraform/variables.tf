# this section defines the variable for the SDDC creation
variable "sddc" {
  type = map(string)
  default = {
    "name"            = ""  # Example: Test-Dev SDDC
    "region"          = ""  # Example: us-west-2
    "vpc_cidr"        = ""  # Example: 10.10.106.0/20
    "vxlan_subnet"    = ""  # Example: 192.168.1.0/24
    "public_ip_name"  = ""  # Example: Public_VM_IP  
    "number_of_hosts" = ""  # Example: 1
    "instance_type"   = ""  # Example: I4I_Metal
    "sddc_type"       = ""  # Example: 1NODE
    "deployment_type" = ""  # Example: SingleAZ
    "provider"        = ""  # Example: AWS
  }
}

variable "aws_acct" {
  default = "xxxxxxxxxx"  # Your AWS Account for the attached VPC.  This VPC is customer owned and is used for shared services
}