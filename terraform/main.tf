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
      resource_group_name  = "ODL-azure-1288109"
      storage_account_name = "tfstate32587"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }  
}

provider "azurerm" {
  # Configuration options
  features {}
}

data "azurerm_resource_group" "example" {
  name = var.resource_group_name
  
}

resource "random_string" "random_string"{
    length = 6
    lower = true
    upper = false
    number = true
    special = false
}

locals {

    keyvault_key_name = substr(lower(join("",
    ["kys",
    substr(next,0,1),
    substr(sid1, 0, 4),
    local.keyvault_name,
    random_string.random_string.result
    ])), 0, 15)
}


# Create an Azure Key Vault
resource "azurerm_key_vault" "example" {
  name                = "example-keyvault"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

# Create a customer-managed key in the Key Vault
resource "azurerm_key_vault_key" "example" {
  name         = local.keyvault_key_name
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "verify"]
}

# Create an Azure Storage Account
resource "azurerm_storage_account" "example" {
  name                     = "examplestorage"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Attach the customer-managed key to the Storage Account
  customer_managed_key {
    key_vault_key_id = azurerm_key_vault_key.example.id
  }
}


# Retrieve the current client configuration
data "azurerm_client_config" "current" {}