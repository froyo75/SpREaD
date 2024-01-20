terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.54.0"
    }
  }
}

provider "aws" {
    access_key = local.aws_hosting[var.aws_region].access_key
    secret_key = local.aws_hosting[var.aws_region].secret_key
    region = local.aws_hosting[var.aws_region].region
}

terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}