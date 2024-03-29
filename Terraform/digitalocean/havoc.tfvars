op_name = "rtX"

hosts = {
  "rtX-c2server-havoc" = {
    do_name                        = "c2server-havoc"
    do_image                       = "debian-10-x64"
    do_size                        = "s-2vcpu-4gb-intel"
    do_region                      = "ams3"
    ansible_user                   = "root"
    ansible_port                   = 22
    vps_ssh_authorized_keys_folder = "./ssh/rtops"
    vps_authorized_key_options     = "from=\"0.0.0.0/0\""
    vps_domain                     = ""
    vps_sshd_port                  = 2222
    vps_admin_email_address        = "rtops@example.com"
    vps_timezone                   = "Europe/Amsterdam"
    vps_service_type               = "c2server"
    vps_dns_provider               = ""
    vps_glue_record		    = false
    vps_dns_template               = ""
    vps_smtp_dkim_domain_key       = ""
    vps_smtp_dkim_selector         = ""
    vps_cdn_endpoints              = ""
    vps_c2_mode                    = ""
    vps_c2_framework               = "havoc"
  }
}
