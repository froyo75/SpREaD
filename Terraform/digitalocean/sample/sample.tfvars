op_name = "rtest1"

hosts = {
  "clonesite-toto-com" = {
    do_name                        = "toto.com"
    do_image                       = "debian-10-x64"
    do_size                        = "s-1vcpu-1gb"
    do_region                      = "ams3"
    ansible_user                   = "root"
    ansible_port                   = 22
    vps_ssh_authorized_keys_folder = "./ssh/rtops"
    vps_authorized_key_options     = "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-user-rc,from=\"0.0.0.0/0\""
    vps_domain                     = "toto.com"
    vps_sshd_port                  = 2222
    vps_admin_email_address        = "rtops@example.com"
    vps_timezone                   = "Europe/Paris"
    vps_service_type               = "clonesite"
    vps_dns_provider               = "gandi"
    vps_glue_record		   = false
    vps_dns_template               = "default-a"
    vps_smtp_dkim_domain_key       = ""
    vps_smtp_dkim_selector         = ""
    vps_c2_mode                    = ""
    vps_c2_framework               = ""
  }
}
