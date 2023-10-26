op_name = "rtX"

hosts = {
  "rtX-evilginx2-toto-com" = {
    do_name                        = "toto.com"
    do_image                       = "debian-10-x64"
    do_size                        = "s-2vcpu-2gb-intel"
    do_region                      = "ams3"
    ansible_user                   = "root"
    ansible_port                   = 22
    vps_ssh_authorized_keys_folder = "./ssh/rtops"
    vps_authorized_key_options     = "from=\"0.0.0.0/0\""
    vps_domain                     = "toto.com"
    vps_sshd_port                  = 2222
    vps_admin_email_address        = "rtops@example.com"
    vps_timezone                   = "Europe/Amsterdam"
    vps_service_type               = "evilginx2"
    vps_dns_provider               = "gandi"
    vps_glue_record		    = true
    vps_dns_template               = ""
    vps_smtp_dkim_domain_key       = ""
    vps_smtp_dkim_selector         = ""
    vps_c2_mode                    = ""
    vps_c2_framework               = ""
  }
}
