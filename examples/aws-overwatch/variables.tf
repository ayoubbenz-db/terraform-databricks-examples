variable "region" {
  default = "eu-west-1"
}

variable "databricks_account_username" {}

variable "databricks_account_password" {
  sensitive = true
}

variable "databricks_account_id" {}