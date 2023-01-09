
resource "random_string" "random" {
    length = 4
    special = false
    lower = true
    upper = false
    numeric = false
}

resource "azurerm_resource_group" "rg" {

    name = "rg-shir-poc-${random_string.random.result}"
    location = var.location
}