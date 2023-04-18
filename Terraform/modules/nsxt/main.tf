terraform {
  required_providers {
    nsxt = {
        source = "vmware/nsxt"
        version = "3.3.0"
    }
  }
}
variable "nsxt_proxy_url" {
  type = string 
  description = "value from main module output."
}
variable "vmc_api_token" {
  type = string
  description = "value from main module output."
}

provider "nsxt" {
  host                  = var.nsxt_proxy_url
  vmc_token             = var.vmc_api_token
  allow_unverified_ssl  = true
  enforcement_point     = "vmc-enforcementpoint"
}
data "nsxt_policy_transport_zone" "overlay_tz" {
  display_name          = "vmc-overlay-tz"
}

/* This section creates network segments */
resource "nsxt_policy_fixed_segment" "vm_network" {
  display_name          = "vm_network"
  description           = "network for VMs"
  connectivity_path     = "/infra/tier-1s/cgw"
  transport_zone_path   = data.nsxt_policy_transport_zone.overlay_tz.site_path
  subnet {
    cidr                = "192.168.10.1/24"
    dhcp_ranges         = ["192.168.10.25-192.168.10.200"]
  }
}
resource "nsxt_policy_fixed_segment" "app_network" {
  display_name          = "app_network"
  description           = "network for VMs"
  connectivity_path     = "/infra/tier-1s/cgw"
  transport_zone_path   = data.nsxt_policy_transport_zone.overlay_tz.site_path
  subnet {
    cidr                = "192.168.20.1/24"
    dhcp_ranges         = ["192.168.20.25-192.168.20.200"]
  }
}

# This section creates FW group(s) in the Compute Gateway
resource "nsxt_policy_group" "cgw_public_inbound" {
  display_name = "CGW_public_inbound"
  description  = "Public access group to local segments"
  domain       = "cgw"
  criteria {
    ipaddress_expression {
      ip_addresses = ["xxx.xxx.xxx.xxx"]
    }
  }
}
resource "nsxt_policy_group" "local_segments" {
  display_name = "local_segments"
  description = "Inbound to local segments"
  domain = "cgw"
  criteria {
    ipaddress_expression {
      ip_addresses = ["xxx.xxx.xxx.xxx"]
    }
  }
}

# This section creates FW group(s) in the Management Gateway
resource "nsxt_policy_group" "mgw_public_inbound" {
  display_name = "mgw_public_inbound"
  description  = "Public access group to vCenter"
  domain       = "mgw"
  criteria {
    ipaddress_expression {
      ip_addresses = ["xxx.xxx.xxx.xxx"]
    }
  }
}

# This section creates FW rules for the Compute Gateway
resource "nsxt_policy_gateway_policy" "cgw_Inbound_access" {
  display_name = "Inbound_access"
  description  = "create initial inbound access policies"
  category     = "LocalGatewayRules"
  domain       = "cgw"
  locked       = false
  stateful     = true
  tcp_strict   = false
  rule {
    action                = "ALLOW"
    description           = "Public inbound to local segments"
    destination_groups    = [nsxt_policy_group.local_segments.path]
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "vCenter_Inbound"
    ip_version            = "IPV4_IPV6"
    scope                 = [ "/infra/labels/cgw-all" ]
    source_groups         = [nsxt_policy_group.cgw_public_inbound.path]
    sources_excluded      = false
  }  
}

# This section creates FW rules for the Management Gateway
resource "nsxt_policy_gateway_policy" "mgw_Inbound_access" {
  display_name = "Inbound_access"
  description  = "create initial inbound access policies"
  category     = "LocalGatewayRules"
  domain       = "mgw"
  locked       = false
  stateful     = true
  tcp_strict   = false
  rule {
    action                = "ALLOW"
    description           = "Public inbound to vCenter"
    destination_groups    = []
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "vCenter_Inbound"
    ip_version            = "IPV4_IPV6"
    scope                 = [ "/infra/labels/mgw" ]
    source_groups         = [nsxt_policy_group.mgw_public_inbound.path]
    sources_excluded      = false
  }
}