# Resource Group Name
output "resource_group_name" {
  value       = azurerm_resource_group.RG.name
  description = "The name of the resource group."
}

# Virtual Network Name
output "virtual_network_name" {
  value       = azurerm_virtual_network.vnet.name
  description = "The name of the virtual network."
}

# Jenkins Subnet ID
output "jenkins_subnet_id" {
  value       = azurerm_subnet.jenkins.id
  description = "The ID of the Jenkins subnet."
}

# SonarQube Subnet ID
output "sonarqube_subnet_id" {
  value       = azurerm_subnet.sonarqube.id
  description = "The ID of the SonarQube subnet."
}

# Jenkins NSG ID
output "jenkins_nsg_id" {
  value       = azurerm_network_security_group.jenkins.id
  description = "The ID of the Jenkins NSG."
}

# SonarQube NSG ID
output "sonarqube_nsg_id" {
  value       = azurerm_network_security_group.sonarqube.id
  description = "The ID of the SonarQube NSG."
}

# Jenkins VM Public IP
output "jenkins_public_ip" {
  value       = azurerm_public_ip.jenkins.ip_address
  description = "The public IP address of the Jenkins VM."
}

# SonarQube VM Public IP
output "sonarqube_public_ip" {
  value       = azurerm_public_ip.sonarqube.ip_address
  description = "The public IP address of the SonarQube VM."
}
