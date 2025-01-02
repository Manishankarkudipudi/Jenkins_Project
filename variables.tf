# Azure Location
variable "location" {
  description = "Azure region for the resources"
  default     = "East US"
}

# Resource Group
variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "JenkinsSonarQubeRG"
}

# Virtual Network
variable "vnet_name" {
  description = "Name of the virtual network"
  default     = "JenkinsSonarQubeVNet"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  default     = ["10.0.0.0/16"]
}

# Subnets
variable "jenkins_subnet_name" {
  description = "Name of the Jenkins subnet"
  default     = "JenkinsSubnet"
}

variable "jenkins_subnet_prefix" {
  description = "Address prefix for the Jenkins subnet"
  default     = ["10.0.1.0/24"]
}

variable "sonarqube_subnet_name" {
  description = "Name of the SonarQube subnet"
  default     = "SonarQubeSubnet"
}

variable "sonarqube_subnet_prefix" {
  description = "Address prefix for the SonarQube subnet"
  default     = ["10.0.2.0/24"]
}

# Network Security Groups
variable "jenkins_nsg_name" {
  description = "Name of the Jenkins NSG"
  default     = "JenkinsNSG"
}

variable "sonarqube_nsg_name" {
  description = "Name of the SonarQube NSG"
  default     = "SonarQubeNSG"
}
