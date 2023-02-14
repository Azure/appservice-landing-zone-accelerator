output "web_app_id" {
    value = coalesce(module.windows_web_app[0].web_app_id)
}

output "web_app_name" {
    value = coalesce(module.windows_web_app[0].web_app_name)
}

output "web_app_hostname" {
    value = coalesce(module.windows_web_app[0].web_app_hostname) 
}

output "web_app_principal_id" {
    value = coalesce(module.windows_web_app[0].web_app_principal_id)
}

output "web_app_slot_id" {
    value = coalesce(module.windows_web_app[0].web_app_slot_id)
}

output "web_app_slot_name" {
    value = coalesce(module.windows_web_app[0].web_app_slot_name)
}

output "web_app_slot_hostname" {
    value = coalesce(module.windows_web_app[0].web_app_slot_hostname)
}

output "web_app_slot_principal_id" {
    value = coalesce(module.windows_web_app[0].web_app_slot_principal_id)
}