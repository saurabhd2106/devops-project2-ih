output "vnet_id" {
  value = module.network.vnet_id
}

output "subnet_ids" {
  value = module.network.subnet_ids
}

output "sql_fqdn" {
  value = module.sql_database.fqdn
}
