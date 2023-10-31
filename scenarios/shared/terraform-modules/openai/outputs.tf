output "openai_endpoint" {
  description = "The endpoint used to connect to the Cognitive Service Account."
  value       = azurerm_cognitive_account.this.endpoint
}

output "openai_primary_key" {
  description = "The primary access key for the Cognitive Service Account."
  sensitive   = true
  value       = azurerm_cognitive_account.this.primary_access_key
}

output "openai_secondary_key" {
  description = "The secondary access key for the Cognitive Service Account."
  sensitive   = true
  value       = azurerm_cognitive_account.this.secondary_access_key
}

output "openai_subdomain" {
  description = "The subdomain used to connect to the Cognitive Service Account."
  value       = azurerm_cognitive_account.this.custom_subdomain_name
}

