terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.94.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  subscription_id            = var.subscription_id
  tenant_id                  = var.tenant_id
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "tags" {
  type    = map(any)
  default = {}
}

resource "azurerm_resource_group" "main" {
  name     = "shatokhin"
  location = "North Europe"

  tags = var.tags
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "shatokhin-cluster"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "shatokhin"

  default_node_pool {
    name            = "main"
    node_count      = 1
    vm_size         = "Standard_D2d_v4"
    os_disk_size_gb = 32
    os_disk_type    = "Ephemeral"
    os_sku          = "AzureLinux"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}
