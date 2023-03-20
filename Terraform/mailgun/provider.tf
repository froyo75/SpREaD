terraform {
  required_providers {
    mailgun = {
      source  = "wgebis/mailgun"
      version = "~> 0.7.1"
    }
  }
}

provider "mailgun" {
  api_key = var.mailgun_token
}

terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}
