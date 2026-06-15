resource "azurerm_federated_identity_credential" "main" {
  name                      = var.name
  user_assigned_identity_id = var.user_assigned_identity_id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = var.issuer
  subject                   = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
}
