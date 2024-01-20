op_name = "rtX"
aws_region = "frankfurt"

hosts = {
  "rtX-mailu-toto-com" = {
    aws_name                       = "mail.toto.com"
    aws_image                      = "ami-05bfef86a955a699e"
    aws_type                       = "t3.small"
    aws_environment                = "PROD"
    ansible_user                   = "admin"
    ansible_port                   = 22
    vps_ssh_authorized_keys_folder = "./ssh/rtops"
    vps_authorized_key_options     = "from=\"0.0.0.0/0\""
    vps_domain                     = "toto.com"
    vps_sshd_port                  = 2222
    vps_admin_email_address        = "rtops@example.com"
    vps_timezone                   = "Europe/Berlin"
    vps_service_type               = "mailu"
    vps_dns_provider               = "gandi"
    vps_glue_record		    = false
    vps_dns_template               = "default-smtp"
    vps_smtp_dkim_domain_key       = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3IHsiMSxb9EDgNlYDUlH"
    vps_smtp_dkim_selector         = "dkim"
    vps_cdn_endpoints              = ""
    vps_c2_mode                    = ""
    vps_c2_framework               = ""
    vps_volume_size                = 25
  }
}
