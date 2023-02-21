output "web_app_id" {
  value = length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_id : module.linux_web_app[0].web_app_id
}

output "web_app_name" {
  value = length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_name : module.linux_web_app[0].web_app_name
}

output "web_app_hostname" {
  value = length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_hostname : module.linux_web_app[0].web_app_hostname
}

output "web_app_principal_id" {
  value = length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_principal_id : module.linux_web_app[0].web_app_principal_id
}

output "web_app_slot_id" {
  value = length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_slot_id : module.linux_web_app[0].web_app_slot_id
}

output "web_app_slot_name" {
  value = length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_slot_name : module.linux_web_app[0].web_app_slot_name
}

output "web_app_slot_hostname" {
  value = length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_slot_hostname : module.linux_web_app[0].web_app_slot_hostname
}

output "web_app_slot_principal_id" {
  value = length(module.windows_web_app) > 0 ? module.windows_web_app[0].web_app_slot_principal_id : module.linux_web_app[0].web_app_slot_principal_id
}
