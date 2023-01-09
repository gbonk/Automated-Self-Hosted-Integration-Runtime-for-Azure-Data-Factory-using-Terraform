#-- Vnet + Subnets ---#
resource "azurerm_virtual_network" "vnet" {
    name = "adf-shir-vnet-${random_string.random.result}"
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = ["10.1.0.0/16"]
    dns_servers = []
}

resource "azurerm_subnet" "default" {
    name = "default"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.1.0.0/24"]
    service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "pe" {
    name = "pe"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.1.1.0/24"]
    service_endpoints = ["Microsoft.Storage"]
    private_endpoint_network_policies_enabled = true
}