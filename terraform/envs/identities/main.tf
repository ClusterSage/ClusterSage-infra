data "azurerm_container_registry" "global_shared" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group_name
}

locals {
  github_oidc_issuer   = "https://token.actions.githubusercontent.com"
  github_oidc_audience = "api://AzureADTokenExchange"

  acr_push_role_name = var.acr_abac_enabled ? (
    "Container Registry Repository Writer"
  ) : "AcrPush"
}

resource "azuread_application" "github_actions" {
  display_name            = var.github_actions_application_name
  sign_in_audience        = "AzureADMyOrg"
  prevent_duplicate_names = true

  owners = [
    var.entra_owner_object_id
  ]
}

resource "azuread_service_principal" "github_actions" {
  client_id                    = azuread_application.github_actions.client_id
  app_role_assignment_required = false

  owners = [
    var.entra_owner_object_id
  ]
}

resource "azuread_application_federated_identity_credential" "github" {
  for_each = var.github_federated_credentials

  application_id = azuread_application.github_actions.id
  display_name   = each.key

  description = coalesce(
    each.value.description,
    "GitHub Actions OIDC credential for ${each.value.subject}"
  )

  audiences = [
    local.github_oidc_audience
  ]

  issuer  = local.github_oidc_issuer
  subject = each.value.subject
}

resource "azurerm_role_assignment" "github_acr_push" {
  scope                = data.azurerm_container_registry.global_shared.id
  role_definition_name = local.acr_push_role_name
  principal_id         = azuread_service_principal.github_actions.object_id

  skip_service_principal_aad_check = true
}
resource "azurerm_role_assignment" "additional" {
  for_each = var.additional_role_assignments

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = azuread_service_principal.github_actions.object_id

  skip_service_principal_aad_check = true
}
