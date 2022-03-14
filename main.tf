# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }

  required_version = ">= 1.0.1"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "RG_VM_cluster"
  location = "West Europe"
}

# Build VNet and 2 subnets 
resource   "azurerm_virtual_network"   "vnet_complete"   { 
   name   =   "vnet_complete" 
   address_space   =   [ "10.0.0.0/16" ] 
   location   =   azurerm_resource_group.rg.location
   resource_group_name   =   azurerm_resource_group.rg.name 
 } 

 resource   "azurerm_subnet"   "external"   { 
   name   =   "external" 
   resource_group_name   =    azurerm_resource_group.rg.name 
   virtual_network_name   =   azurerm_virtual_network.vnet_complete.name
   address_prefixes =  ["10.0.1.0/24"]
 } 

 resource   "azurerm_subnet"   "internal"   { 
   name   =   "internal" 
   resource_group_name   =    azurerm_resource_group.rg.name 
   virtual_network_name   =   azurerm_virtual_network.vnet_complete.name
   address_prefixes  =   ["10.0.2.0/24"]
 } 
#Create public IP 
#Amend this to create a load balancer to replace the vms

resource   "azurerm_public_ip"   "pip1"   { 
   name   =   "pip1" 
   location   =   azurerm_resource_group.rg.location 
   resource_group_name   =   azurerm_resource_group.rg.name 
   allocation_method   =   "Dynamic" 
   sku   =   "Basic" 
 }

 resource   "azurerm_network_interface"   "vm_home_nic1"   { 
   name   =   "vm_home_nic1" 
   location   =   azurerm_resource_group.rg.location
   resource_group_name   =   azurerm_resource_group.rg.name 

   ip_configuration   { 
     name   =   "VM_Home_Ip" 
     subnet_id   =   azurerm_subnet.external.id
     private_ip_address_allocation   =   "Dynamic" 
     public_ip_address_id   =   azurerm_public_ip.pip1.id
    
    
   } 
 } 


# resource "azurerm_network_interface" "vm_home_ext" {
 # name                = "vm_home_ext"
  #location            = azurerm_resource_group.rg.location
  #resource_group_name = azurerm_resource_group.rg.name

 # ip_configuration {
  #  name = "external_ip"
  #  public_ip_address_id   =   azurerm_public_ip.pip1.id
  #  private_ip_address_allocation = "dynamic"
    
    
  #}
#}
 resource   "azurerm_windows_virtual_machine"   "VMHome"   { 
   name                    =   "VMHome"   
   location                =   azurerm_resource_group.rg.location
   resource_group_name     =   azurerm_resource_group.rg.name
   network_interface_ids   =   [azurerm_network_interface.vm_home_nic1.id]
   size                    =   "Standard_D2ads_v5"
   admin_username          =   "adminuser" 
   admin_password          =   "Password123!" 

   source_image_reference   { 
     publisher   =   "MicrosoftWindowsServer" 
     offer       =   "WindowsServer" 
     sku         =   "2022-Datacenter" 
     version     =   "latest" 
   } 

   os_disk   { 
     caching             =   "ReadWrite" 
     storage_account_type   =   "Standard_LRS" 
   } 
 }
