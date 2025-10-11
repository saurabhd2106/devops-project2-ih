resource "azurerm_private_endpoint" "private_endpoints" {
  for_each = var.private_endpoints

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.subnets[each.value.subnet_name].id

  private_service_connection {
    name                           = "${each.key}-connection"
    private_connection_resource_id = each.value.resource_id
    subresource_names              = each.value.subresource_names
    is_manual_connection           = false
  }

  tags = var.tags
}
