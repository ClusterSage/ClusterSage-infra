terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-rg"
    storage_account_name = "norahterraformstorageacc"
    container_name       = "terraformstate"
    key                  = "prod.tfstate"
    use_azuread_auth     = true
    use_oidc             = true
  }
}
