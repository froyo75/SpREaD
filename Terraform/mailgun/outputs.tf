# Provides details about a Mailgun domain
output "mailgun_domain" {
    description = "Mailgun domains"
    value       = {
        for domain in mailgun_domain.mailgun_phish:
          domain.name => format("Domain Settings: %v", domain)
    }
}