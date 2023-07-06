/*
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
}*/

resource "aws_s3_bucket" "log_delivery" {
  bucket = "${var.prefix}-logdelivery"
/*  acl    = "private"
  versioning {
    enabled = false
  }*/
  force_destroy = true
  tags = {
    Name = "${var.prefix}-logdelivery"
  }
}

resource "aws_s3_bucket_public_access_block" "log_delivery" {
  bucket             = aws_s3_bucket.log_delivery.id
  ignore_public_acls = true
}

data "databricks_aws_assume_role_policy" "log_delivery" {
  external_id      = var.databricks_account_id
  for_log_delivery = true
}

resource "aws_iam_role" "log_delivery" {
  name               = "${var.prefix}-logdelivery"
  description        = "(${var.prefix}) UsageDelivery role"
  assume_role_policy = data.databricks_aws_assume_role_policy.log_delivery.json
  # tags               = var.tags
}

data "databricks_aws_bucket_policy" "log_delivery" {
  full_access_role = aws_iam_role.log_delivery.arn
  bucket           = aws_s3_bucket.log_delivery.bucket
}

resource "aws_s3_bucket_policy" "log_delivery" {
  bucket = aws_s3_bucket.log_delivery.id
  policy = data.databricks_aws_bucket_policy.log_delivery.json
}

resource "databricks_mws_credentials" "log_writer" {
  account_id       = var.databricks_account_id
  credentials_name = "Usage Delivery"
  role_arn         = aws_iam_role.log_delivery.arn
}

resource "databricks_mws_storage_configurations" "log_bucket" {
  account_id                 = var.databricks_account_id
  storage_configuration_name = "Usage Logs"
  bucket_name                = aws_s3_bucket.log_delivery.bucket
}

resource "databricks_mws_log_delivery" "usage_logs" {
  account_id               = var.databricks_account_id
  credentials_id           = databricks_mws_credentials.log_writer.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.log_bucket.storage_configuration_id
  // workspace_ids_filter = []
  delivery_path_prefix     = "billable-usage"
  config_name              = "Usage Logs"
  log_type                 = "BILLABLE_USAGE"
  output_format            = "CSV"
}

resource "databricks_mws_log_delivery" "audit_logs" {
  account_id               = var.databricks_account_id
  credentials_id           = databricks_mws_credentials.log_writer.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.log_bucket.storage_configuration_id
  // workspace_ids_filter = []
  delivery_path_prefix     = "audit-logs"
  config_name              = "Audit Logs"
  log_type                 = "AUDIT_LOGS"
  output_format            = "JSON"
}