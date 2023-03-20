# Create a new Mailgun domain
resource "mailgun_domain" "mailgun_phish" {
    
    for_each = var.domains

    name            = each.value.smtp_domain
    region          = each.value.smtp_region
    spam_action     = each.value.spam_action
    smtp_password   = each.value.smtp_password
    dkim_key_size   = each.value.dkim_key_size
    dkim_selector   = each.value.dkim_selector
    wildcard        = true

}