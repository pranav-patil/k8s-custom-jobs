output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_admin_config_raw
  sensitive = true
}

output "id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}

output "host" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.host
}
