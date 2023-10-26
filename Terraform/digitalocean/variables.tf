variable "do_token" {
  type    = string
}

variable "op_name" {
  type    = string
}

variable "team_name" {
  type    = string
  default = "rtops"
}

variable "do_ssh_key_name" {
  type    = string
}
variable "do_ssh_user" {
  type    = string
}

variable "do_ssh_public_key" {
  type    = string
}

variable "do_ssh_private_key" {
  type    = string
}

variable "ansible_path" {
  type    = string
}

variable "dns_token" {
  type    = string
}

variable "hosts" {
  type = map(object({
    do_name                        = string
    do_image                       = string
    do_size                        = string
    do_region                      = string
    ansible_user                   = string
    ansible_port                   = number
    vps_ssh_authorized_keys_folder = string
    vps_authorized_key_options     = string
    vps_domain                     = string
    vps_sshd_port                  = number
    vps_admin_email_address        = string
    vps_timezone                   = string
    vps_service_type               = string
    vps_dns_provider               = string
	  vps_glue_record				         = bool
    vps_dns_template               = string
    vps_smtp_dkim_domain_key       = string
    vps_smtp_dkim_selector         = string
    vps_c2_mode                    = string
    vps_c2_framework               = string
  }))
  default = {
    "test" = {
      do_name                        = "test.infra"
      do_image                       = "debian-10-x64"
      do_size                        = "s-1vcpu-1gb"
      do_region                      = "ams3"
      ansible_user                   = "root"
      ansible_port                   = 22
      vps_ssh_authorized_keys_folder = "./ssh/rtops"
      vps_authorized_key_options     = "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-user-rc,from=\"0.0.0.0/0\""
      vps_domain                     = ""
      vps_sshd_port                  = 2222
      vps_admin_email_address        = "rtops@example.com"
      vps_timezone                   = "Europe/Paris"
      vps_service_type               = ""
      vps_dns_provider               = ""
	    vps_glue_record				         = false
      vps_dns_template               = ""
      vps_smtp_dkim_domain_key       = ""
      vps_smtp_dkim_selector         = ""
      vps_c2_mode                    = ""
      vps_c2_framework               = ""
    }
  }
}
