variable "admin_username" {
    default = "adminuser"
    sensitive = true
}

variable "admin_password" {
    default = "P@$$w0rd1234!"
    sensitive = true
}

variable "resource_group_name" {
    default = "rg-kfir"
}

variable "azurerm_resource_group_location" {
    default = "West Europe"
}

variable "azurerm_windows_virtual_machine_size" {
  default = "Standard_B1s" #cheap for testing 
}
#allow connection  for this port only.
variable "connection-port-range" {
    type = set(string)
    default = ["3389", "3390"]
}

variable "connection-port" {
    default = 3380
}
variable "administrator_login" {
    default = "mradministrator"
    sensitive = true
}
variable "administrator_login_password" {
    default = "thisIsDog11"
    sensitive = true
}
variable "azurerm_storage_account_src_name" {
    default = "aztekkfirsa"
}
variable "azurerm_storage_account_dst_name" {
    default = "dststorageaccount"
}
