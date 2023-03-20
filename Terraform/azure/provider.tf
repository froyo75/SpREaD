terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.85.0"
    }
  }
}

provider "azurerm" {
  features {}
}

terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}