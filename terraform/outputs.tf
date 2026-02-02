# -----------------------------------------------------------------------------
# PERMISSION SETS
# -----------------------------------------------------------------------------

output "permission_set_arns" {
  description = "Map of permission set names to ARNs"
  value       = { for k, v in aws_ssoadmin_permission_set.this : k => v.arn }
}

output "permission_set_ids" {
  description = "Map of permission set names to IDs"
  value       = { for k, v in aws_ssoadmin_permission_set.this : k => v.id }
}

# -----------------------------------------------------------------------------
# GROUPS
# -----------------------------------------------------------------------------

output "group_ids" {
  description = "Map of assignment names to group IDs"
  value       = { for k, v in data.aws_identitystore_group.this : k => v.group_id }
}

# -----------------------------------------------------------------------------
# PERMISSIONS BOUNDARY
# -----------------------------------------------------------------------------

output "permissions_boundary_arn" {
  description = "ARN of the permissions boundary policy"
  value       = var.create_permissions_boundary ? aws_iam_policy.jit_access_boundary[0].arn : null
}

# -----------------------------------------------------------------------------
# MONITORING
# -----------------------------------------------------------------------------

output "cloudwatch_alarm_arns" {
  description = "ARNs of CloudWatch alarms (if monitoring enabled)"
  value = var.enable_monitoring ? {
    console_login_failures = aws_cloudwatch_metric_alarm.console_login_failures[0].arn
    root_account_usage     = aws_cloudwatch_metric_alarm.root_account_usage[0].arn
    iam_policy_changes     = aws_cloudwatch_metric_alarm.iam_policy_changes[0].arn
  } : {}
}
