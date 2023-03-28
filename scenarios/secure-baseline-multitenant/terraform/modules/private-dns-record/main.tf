resource "azurerm_private_dns_a_record" "this" {
  count = length(var.dns_records)

  name                = var.dns_records[count.index].dns_name
  zone_name           = var.dns_records[count.index].zone_name
  resource_group_name = var.resource_group
  ttl                 = 300
  records             = [var.dns_records[count.index].private_ip_address]
}
