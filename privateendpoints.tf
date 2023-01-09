#----- PRIVATE DNS ZONES --------#
#DFS DNS zone  #6:35
resource "azurerm_private_dns_zone" "dfs_privatednszone" {
    name = "privatelink.dfs.core.windows.net"
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnszonevnetlink_000" {
    name = "${azurerm_virtual_network.vnet.name}-dnslink"
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.dfs_privatednszone.name
    virtual_network_id = azurerm_virtual_network.vnet.id
    depends_on = [azurerm_private_dns_zone.dfs_privatednszone]
}

#Blob DNS Zone
resource "azurerm_private_dns_zone" "blob_privatednszone" {
    name = "privatelink.blob.core.windows.net"
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnszonevnetlink_001" {
    name = "${azurerm_virtual_network.vnet.name}-dnslink"
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.blob_privatednszone.name
    virtual_network_id = azurerm_virtual_network.vnet.id
    depends_on = [azurerm_private_dns_zone.blob_privatednszone]
}

#--- Storage Account Private Endpoints andDNS a Records -------#
#DFS
resource "azurerm_private_endpoint" "pe_000" {
    name = "${azurerm_storage_account.storageaccount.name}-dfs"
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
    subnet_id = azurerm_subnet.pe.id

    private_service_connection {
        name = "${azurerm_storage_account.storageaccount.name}-connection"
        private_connection_resource_id = azurerm_storage_account.storageaccount.id
        is_manual_connection = false
        subresource_names = ["dfs"]
    }

    private_dns_zone_group {
        name = azurerm_private_dns_zone.dfs_privatednszone.name
        private_dns_zone_ids = [azurerm_private_dns_zone.dfs_privatednszone.id]
    }
}

resource "azurerm_private_dns_a_record" "privatednsarecord-000" {
    name = azurerm_private_endpoint.pe_000.name
    zone_name =  azurerm_private_dns_zone.dfs_privatednszone.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = "300"
    records = [azurerm_private_endpoint.pe_000.private_service_connection.0.private_ip_address]
    depends_on = [azurerm_private_endpoint.pe_000]
}
#7:02
resource "azurerm_private_endpoint" "pe_001" {
    name = "${azurerm_storage_account.storageaccount.name}-blob"
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
    subnet_id = azurerm_subnet.pe.id

    private_service_connection {
        name = "${azurerm_storage_account.storageaccount.name}-connection"
        private_connection_resource_id = azurerm_storage_account.storageaccount.id
        is_manual_connection = false
        subresource_names = ["blob"]
    }

    private_dns_zone_group {
        name = azurerm_private_dns_zone.blob_privatednszone.name
        private_dns_zone_ids = [azurerm_private_dns_zone.blob_privatednszone.id]
    }
}

resource "azurerm_private_dns_a_record" "privatednsarecord-001" {

    name = azurerm_private_endpoint.pe_001.name
    zone_name =  azurerm_private_dns_zone.blob_privatednszone.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = "300"
    records = [azurerm_private_endpoint.pe_001.private_service_connection.0.private_ip_address]
    depends_on = [azurerm_private_endpoint.pe_001]
}
