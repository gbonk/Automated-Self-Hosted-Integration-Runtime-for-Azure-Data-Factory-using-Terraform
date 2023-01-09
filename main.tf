#9:32

terraform {
    required_version = ">=0.13"
}

provider "azurerm" {
    features {}
}

terraform {

    backend "azurerm" {
        resource_group_name = "rg-terraform"
        storage_account_name = "terraformsadataops1"
        container_name = "dev"
        key = "shir000.tfstate"
    }

}