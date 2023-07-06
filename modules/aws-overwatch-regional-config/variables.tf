variable "databricks_account_username" {}

variable "databricks_account_password" {
  sensitive = true
}

variable "region" {}

variable "databricks_account_id" {
  description = "Account Id that could be found in the bottom left corner of https://accounts.cloud.databricks.com/"
}

variable "prefix" {
  default = "overwatch"
}