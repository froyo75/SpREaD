op_name = "rtX"
aws_region = "paris"

hosts = {
  "rtX-c2-ratel" = {
    aws_name                       = "c2-ratel"
    aws_image                      = "ami-05bfef86a955a699e"
    aws_type                       = "t3.micro"
    aws_environment                = "PROD"
    ansible_user                   = "root"
    ansible_port                   = 22
    vps_ssh_authorized_keys_folder = "./ssh/rtops"
    vps_authorized_key_options     = "from=\"0.0.0.0/0\""
    vps_domain                     = ""
    vps_sshd_port                  = 2222
    vps_admin_email_address        = "rtops@example.com"
    vps_timezone                   = "Europe/Paris"
    vps_service_type               = "c2server"
    vps_dns_provider               = ""
    vps_glue_record		    = false
    vps_dns_template               = ""
    vps_smtp_dkim_domain_key       = ""
    vps_smtp_dkim_selector         = ""
    vps_c2_mode                    = "ratel"
  },
  "rtX-c2-boomerang" = {
    aws_name                       = "c2-boomerang"
    aws_image                      = "ami-05bfef86a955a699e"
    aws_type                       = "t3.micro"
    aws_environment                = "PROD"
    ansible_user                   = "root"
    ansible_port                   = 22
    vps_ssh_authorized_keys_folder = "./ssh/rtops"
    vps_authorized_key_options     = "from=\"0.0.0.0/0\""
    vps_domain                     = ""
    vps_sshd_port                  = 2222
    vps_admin_email_address        = "rtops@example.com"
    vps_timezone                   = "Europe/Paris"
    vps_service_type               = "c2server"
    vps_dns_provider               = ""
    vps_glue_record		   = false
    vps_dns_template               = ""
    vps_smtp_dkim_domain_key       = ""
    vps_smtp_dkim_selector         = ""
    vps_c2_mode                    = "boomerang"
  }
}
