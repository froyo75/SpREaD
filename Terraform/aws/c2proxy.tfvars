op_name = "rtX"
aws_region = "stockholm"

hosts = {
  "rtX-c2proxy-toto-com" = {
    aws_name                       = "toto.com"
    aws_image                      = "ami-05bfef86a955a699e"
    aws_type                       = "t3.micro"
    aws_environment                = "PROD"
    ansible_user                   = "root"
    ansible_port                   = 22
    vps_ssh_authorized_keys_folder = "./ssh/rtops"
    vps_authorized_key_options     = "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-user-rc,from=\"0.0.0.0/0\""
    vps_domain                     = "toto.com"
    vps_sshd_port                  = 2222
    vps_admin_email_address        = "rtops@example.com"
    vps_timezone                   = "Europe/Paris"
    vps_service_type               = "c2proxy"
    vps_dns_provider               = "gandi"
    vps_glue_record		    = false
    vps_dns_template               = "default-a"
    vps_smtp_dkim_domain_key       = ""
    vps_smtp_dkim_selector         = ""
    vps_c2_mode                    = ""
  },
  "rtX-c2proxy-tata-com" = {
    aws_name                       = "tata.com"
    aws_image                      = "ami-05bfef86a955a699e"
    aws_type                       = "t3.micro"
    aws_environment                = "PROD"
    ansible_user                   = "root"
    ansible_port                   = 22
    vps_ssh_authorized_keys_folder = "./ssh/rtops"
    vps_authorized_key_options     = "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-user-rc,from=\"0.0.0.0/0\""
    vps_domain                     = "tata.com"
    vps_sshd_port                  = 2222
    vps_admin_email_address        = "rtops@example.com"
    vps_timezone                   = "Europe/Paris"
    vps_service_type               = "c2proxy"
    vps_dns_provider               = "gandi"
    vps_glue_record		   = false
    vps_dns_template               = "default-a"
    vps_smtp_dkim_domain_key       = ""
    vps_smtp_dkim_selector         = ""
    vps_c2_mode                    = ""
  }
}
