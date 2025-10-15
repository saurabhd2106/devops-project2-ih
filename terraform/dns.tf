# =========================================================
# Private DNS zone for Azure Container Apps internal domain
# =========================================================
resource "azurerm_private_dns_zone" "aca_internal" {
  name                = "nicebeach-3608a673.swedencentral.azurecontainerapps.io"
  resource_group_name = azurerm_resource_group.main.name
}

# =========================================================
# Virtual network link for ACA and App Gateway subnets
# =========================================================
resource "azurerm_private_dns_zone_virtual_network_link" "aca_dns_link" {
  name                  = "burgerbuilder-dns-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.aca_internal.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
}

# =========================================================
# Wildcard DNS record (*.internal-domain)
# =========================================================
resource "azurerm_private_dns_a_record" "aca_internal_wildcard" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.aca_internal.name
  resource_group_name = azurerm_resource_group.main.name
  records             = [var.aca_static_ip]
  ttl                 = 300
}