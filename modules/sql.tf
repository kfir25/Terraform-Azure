# provider "azurerm" {
#   features {}
# }
# resource "azurerm_resource_group" "rg-kfir" {
#   name     = var.resource_group_name
#   location = var.azurerm_resource_group_location
#   tags = {
#     enviroment = "dev"
#   }
# }

resource "azurerm_storage_account" "aztekkfirsa" {
  name                     = var.azurerm_storage_account_src_name
  resource_group_name      = azurerm_resource_group.rg-kfir.name
  location                 = azurerm_resource_group.rg-kfir.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
    blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true
  }

}

resource "azurerm_sql_server" "atzek-kfir-sqlserver" {
  name                         = "atzek-kfir-sqlserver"
  resource_group_name          = azurerm_resource_group.rg-kfir.name
  location                     = azurerm_resource_group.rg-kfir.location
  version                      = "12.0"
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password

  tags = {
    environment = "test"
  }
}

resource "azurerm_sql_database" "aztek-kfir-db" {
  name                = "aztek-kfir-db"
  resource_group_name = azurerm_resource_group.rg-kfir.name
  location            = azurerm_resource_group.rg-kfir.location
  server_name         = azurerm_sql_server.atzek-kfir-sqlserver.name

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.aztekkfirsa.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.aztekkfirsa.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }

  tags = {
    enviroment = "test"
  }

}
#creating replicas 

resource "azurerm_storage_container" "src" {
  name                  = "srcstrcontainer"
  storage_account_name  = azurerm_storage_account.aztekkfirsa.name
  container_access_type = "private"
}
resource "azurerm_resource_group" "dst" {
  name     = "dstResourceGroupName"
  location = "East US"
}

resource "azurerm_storage_account" "dst" {
  name                     = var.azurerm_storage_account_dst_name
  resource_group_name      = azurerm_resource_group.dst.name
  location                 = azurerm_resource_group.dst.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
    blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true
  }

}

resource "azurerm_storage_container" "dst" {
  name                  = "dststrcontainer"
  storage_account_name  = azurerm_storage_account.dst.name
  container_access_type = "private"
}

resource "azurerm_storage_object_replication" "aztek-kfir-replicas" {
  source_storage_account_id      = azurerm_storage_account.aztekkfirsa.id
  destination_storage_account_id = azurerm_storage_account.dst.id
  rules {
    source_container_name      = azurerm_storage_container.src.name
    destination_container_name = azurerm_storage_container.dst.name
  }
}