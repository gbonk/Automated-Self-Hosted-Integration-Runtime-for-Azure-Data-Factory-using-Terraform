#Storage account #5:55
resource "azurerm_storage_account" "storageaccount" {
    name = "shirst${random_string.random.result}"
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    account_tier = "Standard"
    account_replication_type = "LRS"
    account_kind = "StorageV2"
    min_tls_version = "TLS1_2"

    blob_properties {
        cors_rule {
            allowed_headers = ["*"]
            allowed_methods = ["DELETE", "GET", "HEAD", "MERGE", "POST", "OPTIONS", "PUT", "PATCH"]
            allowed_origins = ["*"]
            exposed_headers = ["*"]
            max_age_in_seconds = 200
        }
    }
}

#Storage container and blob
resource "azurerm_storage_container" "newcontainer" {
    name = "shir-script"
    storage_account_name = azurerm_storage_account.storageaccount.name
    container_access_type = "private"
}

resource "azurerm_storage_blob" "newblob" {
    name = "adf-shir.ps1"
    storage_account_name = azurerm_storage_account.storageaccount.name
    storage_container_name = azurerm_storage_container.newcontainer.name
    type = "Block"
    access_tier = "Cool"

    content_md5= md5(file("./gatewayinstall.ps1"))

    source = "./gatewayinstall.ps1"
}

resource "azurerm_storage_account_network_rules" "storageaccountnetworkrules" {

    storage_account_id = azurerm_storage_account.storageaccount.id

    default_action = "Deny"
    ip_rules =  []
    virtual_network_subnet_ids = []
    bypass = ["Metrics", "Logging", "AzureServices"]
    depends_on = [ azurerm_storage_blob.newblob]
}