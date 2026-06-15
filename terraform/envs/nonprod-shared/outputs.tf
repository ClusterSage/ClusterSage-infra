output "resource_group_name" { value = module.resource_group.name }
output "frontdoor_endpoint_hostname" { value = module.frontdoor.endpoint_hostname }
output "frontdoor_custom_domain_validation_tokens" { value = module.frontdoor.custom_domain_validation_tokens }
output "document_intelligence_endpoint" { value = module.ai_services.document_intelligence_endpoint }
output "openai_endpoint" { value = module.ai_services.openai_endpoint }
