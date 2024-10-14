output "web_app_id" {
  value = var.deploy_web_app ? length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_id : module.linux_web_app[0].web_app_id : null
}

output "web_app_name" {
  value = var.deploy_web_app ? length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_name : module.linux_web_app[0].web_app_name : null
}

output "web_app_hostname" {
  value = var.deploy_web_app ? length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_hostname : module.linux_web_app[0].web_app_hostname : null
}

output "web_app_principal_id" {
  value = var.deploy_web_app ? length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_principal_id : module.linux_web_app[0].web_app_principal_id : null
}

output "web_app_slot_id" {
  value = var.deploy_web_app ? length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_slot_ids : module.linux_web_app[0].web_app_slot_ids : null
}

output "web_app_slot_name" {
  value = var.deploy_web_app ? length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_slot_names : module.linux_web_app[0].web_app_slot_names : null
}

output "web_app_slot_hostname" {
  value = var.deploy_web_app ? length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_slot_hostnames : module.linux_web_app[0].web_app_slot_hostnames : null
}

output "web_app_slot_identities" {
  value = var.deploy_web_app ? length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_slot_identities : module.linux_web_app[0].web_app_slot_identities : null
}