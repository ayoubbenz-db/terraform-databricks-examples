data "databricks_mws_credentials" "all" {
  #provider = databricks.mws
}

data "databricks_mws_workspaces" "all" {
  #provider = databricks.mws
}

resource "databricks_mws_workspaces" "overwatch-ws" {
  #provider       = databricks.mws
  account_id     = var.databricks_account_id
  aws_region     = var.region
  workspace_name = "overwatch-ws"

  credentials_id           = data.databricks_mws_credentials.all.id
  #storage_configuration_id = databricks_mws_storage_configurations.this.storage_configuration_id
  #network_id               = databricks_mws_networks.this.network_id

  token {
    comment = "Terraform"
  }
}