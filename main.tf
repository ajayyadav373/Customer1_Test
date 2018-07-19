
resource "azurerm_resource_group" "rg_test" {
  name     = "Test_ajay_rg"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet_test" {
  name                = "Test_vnet"
  location            = "${var.location}"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = "${azurerm_resource_group.rg_test.name}"
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  virtual_network_name = "${azurerm_virtual_network.vnet_test.name}"
  resource_group_name  = "${azurerm_resource_group.rg_test.name}"
  address_prefix       = "10.0.0.0/24"
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  virtual_network_name = "${azurerm_virtual_network.vnet_test.name}"
  resource_group_name  = "${azurerm_resource_group.rg_test.name}"
  address_prefix       = "10.0.1.0/24"
}
resource "azurerm_subnet" "subnet3" {
  name                 = "subnet3"
  virtual_network_name = "${azurerm_virtual_network.vnet_test.name}"
  resource_group_name  = "${azurerm_resource_group.rg_test.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "ni_test" {
  name                = "Ajay_Net_Int"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg_test.name}"

  ip_configuration {
    name                          = "Ajay_testipconf"
    subnet_id                     = "${azurerm_subnet.subnet2.id}"
    private_ip_address_allocation = "dynamic"
  }
}


resource "azurerm_managed_disk" "test_disk" {
  name                 = "datadisk_existing"
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.rg_test.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"
}


resource "azurerm_virtual_machine" "Test_VM" {
  name                  = "Test_Ajay_Terraform"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg_test.name}"
  network_interface_ids = ["${azurerm_network_interface.ni_test.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
 
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "datadisk_new"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "1023"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.test_disk.name}"
    managed_disk_id = "${azurerm_managed_disk.test_disk.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.test_disk.disk_size_gb}"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "staging"
  }
}

