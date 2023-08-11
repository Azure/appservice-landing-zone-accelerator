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
  value = var.deploy_web_app ? length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_slot_id : module.linux_web_app[0].web_app_slot_id : null
}

output "web_app_slot_name" {
  value = var.deploy_web_app ? length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_slot_name : module.linux_web_app[0].web_app_slot_name : null
}

output "web_app_slot_hostname" {
  value = var.deploy_web_app ? length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_slot_hostname : module.linux_web_app[0].web_app_slot_hostname : null
}

output "web_app_slot_principal_id" {
  value = var.deploy_web_app ? length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_slot_principal_id : module.linux_web_app[0].web_app_slot_principal_id : null
}