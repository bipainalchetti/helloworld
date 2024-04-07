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
      resource_group_name  = "ODL-azure-1288824"
      storage_account_name = "tfstate25719"
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
  name     = "ODL-azure-1288824"
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "example-identity"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location
}

resource "azurerm_storage_account" "example" {
  name                     = "examplestorage1288824"
  resource_group_name      = data.azurerm_resource_group.example.name
  location                 = data.azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }
}

resource "azurerm_key_vault" "example" {
  name                = "examplekeyvault1288824"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "UnwrapKey",
      "WrapKey",
      "GetRotationPolicy",
      "SetRotationPolicy"
    ]
  }
}

resource "azurerm_key_vault_key" "example" {
  name         = "examplekey1288824"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["unwrapKey", "wrapKey"]
}

resource "azurerm_storage_account_customer_managed_key" "example" {
  storage_account_id = azurerm_storage_account.example.id
  key_vault_id       = azurerm_key_vault.example.id
  key_name           = azurerm_key_vault_key.example.name
  user_assigned_identity_id = azurerm_user_assigned_identity.example.id
}

# Retrieve the current client configuration
data "azurerm_client_config" "current" {}