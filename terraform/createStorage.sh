#!/bin/bash

RESOURCE_GROUP_NAME=ODL-azure-1287978
STORAGE_ACCOUNT_NAME=tfstatebpsea
CONTAINER_NAME=tfstate
# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME