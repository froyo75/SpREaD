variable "op_name" {
  type    = string
}

variable "cdn_profile_name" {
  type    = string
}

variable "cdn_location" {
  type    = string
  default = "northeurope"
}

variable "cdn_domain" {
  type    = string
  default = "azureedge.net"
}

variable "endpoints" {
  type = map(object({
    cdn_endpoint_name          = string
    cdn_origin_hostname        = string
    cdn_origin_hostname_header = string
  }))
  default = {
    "test-com" = {
        cdn_endpoint_name = "test"
        cdn_origin_hostname  = "test.com"
        cdn_origin_hostname_header = "test.com"
    }
  }
}