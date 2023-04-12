resource "random_string" "strapp" {
  length  = 5
  lower = true
  upper = false
  special = false
}

module "aws-overwatch" {
  source = "../../modules/aws-overwatch"

  databricks_account_id       = var.databricks_account_id
  databricks_account_username = var.databricks_account_username
  databricks_account_password = var.databricks_account_password
  region                      = var.region
}