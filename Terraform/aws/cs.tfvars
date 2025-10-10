op_name = "rtX"
aws_region = "zurich"

hosts = {
  "rtX-c2server-cs" = {
    aws_name                       = "c2server-cs"
    aws_image                      = "ami-07b4dc095bc9bce30"
    aws_type                       = "t3.medium"
    aws_environment                = "PROD"
    ansible_user                   = "admin"
    ansible_port                   = 22
    vps_ssh_authorized_keys_folder = "./ssh/rtops"
    vps_authorized_key_options     = "from=\"0.0.0.0/0\""
    vps_domain                     = ""
    vps_sshd_port                  = 2222
    vps_admin_email_address        = "rtops@example.com"
    vps_timezone                   = "Europe/Zurich"
    vps_service_type               = "c2server"
    vps_dns_provider               = ""
    vps_glue_record		    = false
    vps_dns_template               = ""
    vps_smtp_dkim_domain_key       = ""
    vps_smtp_dkim_selector         = ""
    vps_cdn_endpoints              = ""
    vps_c2_mode                    = ""
    vps_c2_framework               = "cobaltstrike"
    vps_volume_size                = 35
  }
}
