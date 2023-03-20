variable "mailgun_token" {
  type    = string
}

variable "domains" {
  type = map(object({
    smtp_domain   = string
    smtp_region   = string
    spam_action   = string
    smtp_password = string
    dkim_key_size = number
    dkim_selector = string
  }))
  default = {
    "test-com" = {
        smtp_domain = "test.com"
        smtp_region = "eu"
        spam_action = "disabled"
        smtp_password = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        dkim_key_size = 2048
        dkim_selector = "mx"
    }
  }
}
