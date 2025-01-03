terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.9.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "2becfaf7-7e71-47da-9b18-e6b51ec28023"
}

# Resource Group
resource "azurerm_resource_group" "RG" {
  name     = "JenkinsSonarQubeRG"
  location = "East US"
}

# RBAC Role Assignment
resource "azurerm_role_assignment" "role" {
  principal_id         = "1fa98688-346d-4cd7-a5a5-f8789e267fbd"
  role_definition_name = "Reader"
  scope                = "/subscriptions/2becfaf7-7e71-47da-9b18-e6b51ec28023"  
}



data "azurerm_policy_assignment" "existing_policy_assignment" {
  name     = "6a55b2e153464079871e817f"  
  scope_id = "/subscriptions/2becfaf7-7e71-47da-9b18-e6b51ec28023"
}



# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "JenkinsSonarQubeVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
}

# Subnet for Jenkins
resource "azurerm_subnet" "jenkins" {
  name                 = "JenkinsSubnet"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Subnet for SonarQube
resource "azurerm_subnet" "sonarqube" {
  name                 = "SonarQubeSubnet"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group for Jenkins
resource "azurerm_network_security_group" "jenkins" {
  name                = "JenkinsNSG"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Security Group for SonarQube
resource "azurerm_network_security_group" "sonarqube" {
  name                = "SonarQubeNSG"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with Subnets
resource "azurerm_subnet_network_security_group_association" "jenkins" {
  subnet_id                 = azurerm_subnet.jenkins.id
  network_security_group_id = azurerm_network_security_group.jenkins.id
}

resource "azurerm_subnet_network_security_group_association" "sonarqube" {
  subnet_id                 = azurerm_subnet.sonarqube.id
  network_security_group_id = azurerm_network_security_group.sonarqube.id
}

# Public IP for Jenkins VM
resource "azurerm_public_ip" "jenkins" {
  name                = "JenkinsPublicIP"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  allocation_method   = "Static"
}

# Public IP for SonarQube VM
resource "azurerm_public_ip" "sonarqube" {
  name                = "SonarQubePublicIP"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  allocation_method   = "Static"
}

# NIC for Jenkins VM
resource "azurerm_network_interface" "jenkins_nic" {
  name                = "JenkinsNIC"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "jenkins-ip-config"
    subnet_id                     = azurerm_subnet.jenkins.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkins.id
  }
}

# NIC for SonarQube VM
resource "azurerm_network_interface" "sonarqube_nic" {
  name                = "SonarQubeNIC"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "sonarqube-ip-config"
    subnet_id                     = azurerm_subnet.sonarqube.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sonarqube.id
  }
}

resource "azurerm_linux_virtual_machine" "jenkins_vm" {
  name                            = "JenkinsVM"
  location                        = azurerm_resource_group.RG.location
  resource_group_name             = azurerm_resource_group.RG.name
  size                            = "Standard_B1s"
  admin_username                  = "azureadmin"
  disable_password_authentication = false # Enable password authentication

  network_interface_ids = [azurerm_network_interface.jenkins_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_password = "Mani@shankar2415"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "sonarqube_vm" {
  name                            = "SonarQubeVM"
  location                        = azurerm_resource_group.RG.location
  resource_group_name             = azurerm_resource_group.RG.name
  size                            = "Standard_B1s"
  admin_username                  = "azureadmin"
  disable_password_authentication = false # Enable password authentication

  network_interface_ids = [azurerm_network_interface.sonarqube_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_password = "Mani@shankar2415"

  tags = {
    environment = "dev"
  }
}


# Assign Reader Role to a User/Service Principal at the Resource Group Level
resource "azurerm_role_assignment" "reader_role" {
  principal_id   = "1fa98688-346d-4cd7-a5a5-f8789e267fbd"  # Replace with the Object ID of the user or service principal
  role_definition_name = "Reader"
  scope = azurerm_resource_group.RG.id
}
