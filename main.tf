
data "azurerm_client_config" "current" {}
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}
resource "azurerm_key_vault" "key_vault" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey"
    ]
    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Restore",
      "Recover",
      "Set",
      "List",
    ]
  }
}

resource "azurerm_key_vault_secret" "key_vault_secret" {
  name         = "adminuser"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.key_vault.id
}


resource "azurerm_mysql_server" "mysql_server" {
  name                              = var.name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  administrator_login               = var.administrator_login
  administrator_login_password      = random_password.password.result
  sku_name                          = var.sku_name
  storage_mb                        = var.storage_mb
  version                           = var.mysql_version
  auto_grow_enabled                 = var.auto_grow_enabled
  backup_retention_days             = var.backup_retention_days
  geo_redundant_backup_enabled      = var.geo_redundant_backup_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  ssl_enforcement_enabled           = var.ssl_enforcement_enabled
  ssl_minimal_tls_version_enforced  = var.ssl_minimal_tls_version_enforced
  threat_detection_policy {
    enabled = true
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_mysql_firewall_rule" "example" {
  name                = "office"
  resource_group_name = azurerm_mysql_server.mysql_server.resource_group_name
  server_name         = azurerm_mysql_server.mysql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
