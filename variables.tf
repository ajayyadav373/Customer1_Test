variable subscription_id {}
variable tenant_id {}
variable client_id {}
variable client_secret {}

provider "azurerm" {
    subscription_id = "${var.subscription_id}"
    tenant_id = "${var.tenant_id}"
    client_id = "${var.client_id}"
    client_secret = "${var.client_secret}"
}


variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  default     = "South India"
}
