terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = "55e0a918-ce6b-4e95-ada3-ac945c30536b" # Subscription ID for C1 Cloud Native Security
}

# Resource group for the AKS cluster
resource "azurerm_resource_group" "aks_rg" {
  name     = "${var.stack_name}-aks-resource-group"
  location = var.region
}

# Virtual network for AKS
resource "azurerm_virtual_network" "aks_vnet" {
  name                = "${var.stack_name}-aks-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

# Subnet for AKS nodes
resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.stack_name}-aks-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${var.stack_name}-aks-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "aksdns"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_vm_size
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  # Ensure deletion protection is disabled to allow easy deletion of the cluster
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Environment = "Development"
  }
}

