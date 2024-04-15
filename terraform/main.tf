terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.53.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "ODL-azure-1296088"
      storage_account_name = "tfstate1296088"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }  
}

provider "azurerm" {
  # Configuration options
  features {}
}

# Create a Resource Group
data "azurerm_resource_group" "example" {
  name     = "ODL-azure-1296088"
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "example-identity"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location
}

resource "azurerm_storage_account" "example" {
  name                     = "examplestorage12960885"
  resource_group_name      = data.azurerm_resource_group.example.name
  location                 = data.azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }
}


# Retrieve the current client configuration
data "azurerm_client_config" "current" {}