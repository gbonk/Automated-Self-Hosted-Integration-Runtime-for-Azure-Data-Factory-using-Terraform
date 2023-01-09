#7:32
#VM Network Interface
resource "azurerm_network_interface" "nic" {
    name = "shir-vm-nic-${random_string.random.result}"
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.pe.id
        private_ip_address_allocation = "Dynamic"
    }
}


#WindowsVM
resource "azurerm_windows_virtual_machine" "main" {
    name = "shir-vm-${random_string.random.result}"
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.nic.id]
    size = "Standard_B2s"
    admin_username = "testadmin"
    admin_password = "Password1234!"

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2022-datacenter"
        version = "latest"
    }

    os_disk {
        name =  "myosdisk1"
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    identity {
        type = "SystemAssigned"
    }
}

#8:33
#VM Customer Script Extension
resource "azurerm_virtual_machine_extension" "vmextension-0000" {

    name = "ADF_SHIR"
    virtual_machine_id =  azurerm_windows_virtual_machine.main.id
    publisher = "Microsoft.Compute"
    type = "CustomScriptExtension"
    type_handler_version = "1.10"
    auto_upgrade_minor_version = true

    protected_settings = <<PROTECTED_SETTINGS

    {
        "fileUris": ["${format("https://%s.blob.core.windows.net/%s/%s", azurerm_storage_account.storageaccount.name,azurerm_storage_container.newcontainer.name, azurerm_storage_blob.newblob.name)}"],
        "commandToExecute": "${join( " ", ["powershell.exe -ExecutionPolicy Unrestricted -File", azurerm_storage_blob.newblob.name, "-gatewayKey ${azurerm_data_factory_integration_runtime_self_hosted.shir.primary_authorization_key}"])}",
        "storageAccountName": "${azurerm_storage_account.storageaccount.name}",
        "storageAccountKey": "${azurerm_storage_account.storageaccount.primary_access_key}"
    }
PROTECTED_SETTINGS


}

