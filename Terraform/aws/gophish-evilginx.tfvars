op_name = "rtX"
aws_region = "london"

hosts = {
  "rtX-gophish-toto-com" = {
    aws_name                       = "toto.com"
    aws_image                      = "ami-0e16e78fb9cb2fc71"
    aws_type                       = "t3.micro"
    aws_environment                = "PROD"
    ansible_user                   = "admin"
    ansible_port                   = 22
    vps_ssh_authorized_keys_folder = "./ssh/rtops"
    vps_authorized_key_options     = "from=\"0.0.0.0/0\""
    vps_domain                     = "toto.com"
    vps_sshd_port                  = 2222
    vps_admin_email_address        = "rtops@example.com"
    vps_timezone                   = "Europe/London"
    vps_service_type               = "gophish-evilginx"
    vps_dns_provider               = "gandi"
    vps_glue_record		    = false
    vps_dns_template               = "mailgun-eu"
    vps_smtp_dkim_domain_key       = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3IHsiMSxb9EDgNlYDUlH"
    vps_smtp_dkim_selector         = "mx"
    vps_cdn_endpoints              = ""
    vps_c2_mode                    = ""
    vps_c2_framework               = ""
    vps_volume_size                = 25
  },
  "rtX-gophish-tata-com" = {
    aws_name                       = "tata.com"
    aws_image                      = "ami-0e16e78fb9cb2fc71"
    aws_type                       = "t3.micro"
    aws_environment                = "PROD"
    ansible_user                   = "admin"
    ansible_port                   = 22
    vps_ssh_authorized_keys_folder = "./ssh/rtops"
    vps_authorized_key_options     = "from=\"0.0.0.0/0\""
    vps_domain                     = "tata.com"
    vps_sshd_port                  = 2222
    vps_admin_email_address        = "rtops@example.com"
    vps_timezone                   = "Europe/London"
    vps_service_type               = "gophish-evilginx"
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
