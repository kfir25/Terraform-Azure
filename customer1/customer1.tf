#This is an example for one customer - use custom parameters

module "aztek-kfir-win-sql" {
  source = "../modules"
  azurerm_resource_group_location = "North Europe"
  resource_group_name = "customer-RG"
  connection-port-range = ["3389", "3390"]
  connection-port = "3555"
  azurerm_windows_virtual_machine_size = "Standard_B1s"
  azurerm_storage_account_src_name = "somerandomnameaz"
  azurerm_storage_account_dst_name = "someotherrandomnameaz"
}