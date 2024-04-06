# Configure the Azure Provider
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
      resource_group_name  = "ODL-azure-1288206"
      storage_account_name = "tfstate13344"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }  
}
# Create a Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "ODL-azure-1288220"
  location = "eastus"
}

# Create a Key Vault
resource "azurerm_key_vault" "keyvault" {
  name                        = "odlkeyvault1288220"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get", "list", "create", "delete", "update",
    ]

    secret_permissions = [
      "get", "list", "set", "delete",
    ]

    storage_permissions = [
      "get", "list",
    ]
  }
}

# Create a Key in the Key Vault
resource "azurerm_key_vault_key" "key" {
  name         = "storage-account-key"
  key_vault_id = azurerm_key_vault.keyvault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

# Create a Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "odlstorage1288220"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Associate the Key from Key Vault with the Storage Account
  customer_managed_key {
    key_vault_key_id = azurerm_key_vault_key.key.id
    key_name         = azurerm_key_vault_key.key.name
  }
}