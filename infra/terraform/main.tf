############################
# Resource Group
############################
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name # سيكون "project2-teaf"
  location = var.location            # ستكون "Italy North"
  tags     = var.tags
}


############################
# Log Analytics + App Insights
############################
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.name_prefix}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "appi" {
  name                = "${var.name_prefix}-appi"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.law.id
  application_type    = "web"
  tags                = var.tags
}

############################
# Networking: VNet + Subnets
############################
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name_prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "snet_appgw" {
  name                 = "snet-appgw"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "snet_frontend" {
  name                 = "snet-frontend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "snet_backend" {
  name                 = "snet-backend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "snet_data" {
  name                              = "snet-data"
  resource_group_name               = azurerm_resource_group.rg.name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  address_prefixes                  = ["10.0.3.0/24"]
  private_endpoint_network_policies = "Disabled" # مطلوب للـ Private Endpoint
}

resource "azurerm_subnet" "snet_ops" {
  name                 = "snet-ops"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/24"]
}

# Bastion subnet (لازم اسم خاص وحجم /26 أو أكبر)
resource "azurerm_subnet" "snet_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.5.0/26"]
}

############################
# NSGs لكل Subnet (قواعد محكمة)
############################
resource "azurerm_network_security_group" "nsg_frontend" {
  name                = "${var.name_prefix}-nsg-frontend"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  security_rule {
    name                       = "allow_appgw_to_http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.frontend_port)
    source_address_prefixes    = ["10.0.0.0/24"] # snet-appgw
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_ops_ssh"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = ["10.0.4.0/24"] # snet-ops
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "as_frontend" {
  subnet_id                 = azurerm_subnet.snet_frontend.id
  network_security_group_id = azurerm_network_security_group.nsg_frontend.id
}

resource "azurerm_network_security_group" "nsg_backend" {
  name                = "${var.name_prefix}-nsg-backend"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  security_rule {
    name                       = "allow_appgw_to_api"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.backend_port)
    source_address_prefixes    = ["10.0.0.0/24"] # snet-appgw
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_ops_ssh"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = ["10.0.4.0/24"] # snet-ops
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "as_backend" {
  subnet_id                 = azurerm_subnet.snet_backend.id
  network_security_group_id = azurerm_network_security_group.nsg_backend.id
}

resource "azurerm_network_security_group" "nsg_ops" {
  name                = "${var.name_prefix}-nsg-ops"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  security_rule {
    name                       = "allow_bastion_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = ["10.0.5.0/26"] # AzureBastionSubnet
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "as_ops" {
  subnet_id                 = azurerm_subnet.snet_ops.id
  network_security_group_id = azurerm_network_security_group.nsg_ops.id
}

############################
# Public IPs: AppGW + Bastion
############################
resource "azurerm_public_ip" "agw_pip" {
  name                = "${var.name_prefix}-agw-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_public_ip" "bastion_pip" {
  name                = "${var.name_prefix}-bastion-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

############################
# Bastion Host (إدارة فقط)
############################
resource "azurerm_bastion_host" "bastion" {
  name                = "${var.name_prefix}-bastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "bastion-ipcfg"
    subnet_id            = azurerm_subnet.snet_bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }

  tags = var.tags
}

############################
# Network Interfaces + VMs
############################
resource "azurerm_network_interface" "nic_fe" {
  name                = "${var.name_prefix}-nic-fe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipcfg"
    subnet_id                     = azurerm_subnet.snet_frontend.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.fe_ip
  }

  tags = var.tags
}

resource "azurerm_network_interface" "nic_api" {
  name                = "${var.name_prefix}-nic-api"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipcfg"
    subnet_id                     = azurerm_subnet.snet_backend.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.api_ip
  }

  tags = var.tags
}

resource "azurerm_network_interface" "nic_ops" {
  name                = "${var.name_prefix}-nic-ops"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipcfg"
    subnet_id                     = azurerm_subnet.snet_ops.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ops_ip
  }

  tags = var.tags
}

# صورة Ubuntu 22.04 لثبات أعلى
locals {
  linux_image = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "vm_fe" {
  name                            = "${var.name_prefix}-vm-frontend"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  network_interface_ids           = [azurerm_network_interface.nic_fe.id]
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_pubkey
  }

  source_image_reference {
    publisher = local.linux_image.publisher
    offer     = local.linux_image.offer
    sku       = local.linux_image.sku
    version   = local.linux_image.version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm_api" {
  name                            = "${var.name_prefix}-vm-backend"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  network_interface_ids           = [azurerm_network_interface.nic_api.id]
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_pubkey
  }

  source_image_reference {
    publisher = local.linux_image.publisher
    offer     = local.linux_image.offer
    sku       = local.linux_image.sku
    version   = local.linux_image.version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm_ops" {
  name                            = "${var.name_prefix}-vm-ops"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  network_interface_ids           = [azurerm_network_interface.nic_ops.id]
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_pubkey
  }

  source_image_reference {
    publisher = local.linux_image.publisher
    offer     = local.linux_image.offer
    sku       = local.linux_image.sku
    version   = local.linux_image.version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = var.tags
}

############################
# SQL Server + Database (Public Disabled)
############################
resource "azurerm_mssql_server" "sql" {
  name                          = "${var.name_prefix}-sqlsrv"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "12.0"
  administrator_login           = var.sql_admin_user
  administrator_login_password  = var.sql_admin_password
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  tags                          = var.tags
}

resource "azurerm_mssql_database" "sqldb" {
  name                 = "${var.name_prefix}-db"
  server_id            = azurerm_mssql_server.sql.id
  sku_name             = var.sql_sku_name # S0
  zone_redundant       = false
  tags                 = var.tags
  storage_account_type = "Local"
  geo_backup_enabled   = false
}

# Private DNS Zone + Link
resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_link" {
  name                  = "${var.name_prefix}-sql-dnslink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  tags                  = var.tags
}

# Private Endpoint للـ SQL
resource "azurerm_private_endpoint" "sql_pe" {
  name                = "${var.name_prefix}-sql-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet_data.id

  private_service_connection {
    name                           = "sql-pe-conn"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sql-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql.id]
  }

  tags = var.tags
}

