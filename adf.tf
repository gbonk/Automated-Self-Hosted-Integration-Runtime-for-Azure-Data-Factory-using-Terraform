#8:28
resource "azurerm_data_factory" "adf" {
    name = "adf-poc-${random_string.random.result}"
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "shir" {
    name = "adf-poc-shir"
#    resource_group_name = azurerm_resource_group.rg.name
    data_factory_id = azurerm_data_factory.adf.id
}