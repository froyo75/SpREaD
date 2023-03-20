op_name = "rtX"

hosts = {
  "rtX-recon-manual" = {
    do_name                        = "recon-manual"
    do_image                       = "debian-10-x64"
    do_size                        = "s-1vcpu-1gb"
    do_region                      = "ams3"
    ansible_user                   = "root"
    ansible_port                   = 22
    vps_ssh_authorized_keys_folder = "./ssh/rtops"
    vps_authorized_key_options     = "from=\"0.0.0.0/0\""
    vps_domain                     = ""
    vps_sshd_port                  = 2222
    vps_admin_email_address        = "rtops@example.com"
    vps_timezone                   = "Europe/Paris"
    vps_service_type               = "recon"
    vps_dns_provider               = ""
    vps_glue_record		    = false
    vps_dns_template               = ""
    vps_smtp_dkim_domain_key       = ""
    vps_smtp_dkim_selector         = ""
    vps_c2_mode                    = ""
  },
  "rtX-recon-axiom" = {
    do_name                        = "recon-axiom"
    do_image                       = "debian-10-x64"
    do_size                        = "s-1vcpu-2gb-intel"
    do_region                      = "fra1"
    ansible_user                   = "root"
    ansible_port                   = 22
    vps_ssh_authorized_keys_folder = "./ssh/rtops"
    vps_authorized_key_options     = "from=\"0.0.0.0/0\""
    vps_domain                     = ""
    vps_sshd_port                  = 2222
    vps_admin_email_address        = "rtops@example.com"
    vps_timezone                   = "Europe/Paris"
    vps_service_type               = "axiom"
    vps_dns_provider               = ""
    vps_glue_record		   = false
    vps_dns_template               = ""
    vps_smtp_dkim_domain_key       = ""
    vps_smtp_dkim_selector         = ""
    vps_c2_mode                    = ""
  }
}
