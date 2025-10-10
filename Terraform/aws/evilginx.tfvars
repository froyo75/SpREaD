op_name = "rtX"
aws_region = "frankfurt"

hosts = {
  "rtX-evilginx-toto-com" = {
    aws_name                       = "toto.com"
    aws_image                      = "ami-0f439e819ba112bd7"
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
    vps_service_type               = "evilginx"
    vps_dns_provider               = "gandi"
    vps_glue_record		    = true
    vps_dns_template               = ""
    vps_smtp_dkim_domain_key       = ""
    vps_smtp_dkim_selector         = ""
    vps_cdn_endpoints              = ""
    vps_c2_mode                    = ""
    vps_c2_framework               = ""
    vps_volume_size                = 25
  }
}
