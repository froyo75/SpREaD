locals {
  aws_hosting = tomap({
    paris = {
        access_key = var.aws_access_key_id
        secret_key = var.aws_secret_access_key
        region = "eu-west-3"
    }
    london = {
        access_key = var.aws_access_key_id
        secret_key = var.aws_secret_access_key
        region = "eu-west-2"
    }
    ireland = {
        access_key = var.aws_access_key_id
        secret_key = var.aws_secret_access_key
        region = "eu-west-1"
    }
    stockholm = {
        access_key = var.aws_access_key_id
        secret_key = var.aws_secret_access_key
        region = "eu-north-1"
    }
    frankfurt = {
        access_key = var.aws_access_key_id
        secret_key = var.aws_secret_access_key
        region = "eu-central-1"
    }
  })
}

variable "aws_region" {
  type    = string
}

variable "aws_access_key_id" {
  type    = string
}

variable "aws_secret_access_key" {
  type    = string
}

variable "op_name" {
  type    = string
}

variable "aws_ssh_key_name" {
  type    = string
}
variable "aws_ssh_user" {
  type    = string
}

variable "aws_ssh_public_key" {
  type    = string
}

variable "aws_ssh_private_key" {
  type    = string
}

variable "team_name" {
  type    = string
  default = "rtops"
}

variable "ansible_path" {
  type    = string
}

variable "dns_token" {
  type    = string
}

variable "hosts" {
  type = map(object({
    aws_name                        = string
    aws_image                       = string
    aws_type                        = string
    aws_environment                 = string
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
      aws_name                        = "test.infra"
      aws_image                       = "ami-05bfef86a955a699e"
      aws_type                        = "t3.micro"
      aws_environment                = "DEV"
      ansible_user                   = "root"
      ansible_port                   = 22
      vps_ssh_authorized_keys_folder = "./ssh/rtops"
      vps_authorized_key_options     = "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-user-rc,from=\"0.0.0.0/0\""
      vps_domain                     = ""
      vps_sshd_port                  = 2222
      vps_admin_email_address        = "rtops@example.com"
      vps_timezone                   = "Europe/Paris"
      vps_service_type               = "recon"
      vps_dns_provider               = ""
	  vps_glue_record				 = false
      vps_dns_template               = ""
      vps_smtp_dkim_domain_key       = ""
      vps_smtp_dkim_selector         = ""
      vps_c2_mode                    = ""
      vps_c2_framework               = ""
    }
  }
}
