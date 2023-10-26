op_name = "rtX"

hosts = {
  "rtX-mailu-toto-com" = {
    do_name                        = "mail.toto.com"
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
    vps_service_type               = "mailu"
    vps_dns_provider               = "gandi"
    vps_glue_record		    = false
    vps_dns_template               = "default-smtp"
    vps_smtp_dkim_domain_key       = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3IHsiMSxb9EDgNlYDUlH"
    vps_smtp_dkim_selector         = "dkim"
    vps_c2_mode                    = ""
    vps_c2_framework               = ""
  }
}
