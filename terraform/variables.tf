# -----------------------------------------------------------------------------
# REQUIRED VARIABLES
# -----------------------------------------------------------------------------

variable "identity_store_id" {
  description = "IAM Identity Center Identity Store ID (e.g., d-1234567890)"
  type        = string

  validation {
    condition     = can(regex("^d-[a-z0-9]{10}$", var.identity_store_id))
    error_message = "Identity Store ID must match pattern d-xxxxxxxxxx."
  }
}

variable "instance_arn" {
  description = "IAM Identity Center Instance ARN"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:sso:::instance/ssoins-", var.instance_arn))
    error_message = "Instance ARN must be a valid SSO instance ARN."
  }
}

# -----------------------------------------------------------------------------
# OPTIONAL VARIABLES
# -----------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "default_tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Purpose   = "JIT-Access"
  }
}

variable "permissions_boundary_arn" {
  description = "ARN of permissions boundary policy (optional)"
  type        = string
  default     = null

  validation {
    condition     = var.permissions_boundary_arn == null || can(regex("^arn:aws:iam::", var.permissions_boundary_arn))
    error_message = "Permissions boundary must be a valid IAM policy ARN."
  }
}

variable "alarm_sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarm notifications (optional)"
  type        = string
  default     = null
}

variable "cloudtrail_log_group_name" {
  description = "CloudWatch Log Group name for CloudTrail logs (optional)"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# PERMISSION SETS
# -----------------------------------------------------------------------------

variable "permission_sets" {
  description = "Map of permission sets to create"
  type = map(object({
    description      = string
    session_duration = optional(string, "PT1H")
    managed_policies = optional(list(string), [])
    inline_policy    = optional(string, "")
    relay_state      = optional(string, "")
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.permission_sets :
      can(regex("^PT([1-9]|1[0-2])H$", v.session_duration))
    ])
    error_message = "Session duration must be between PT1H and PT12H."
  }
}

# -----------------------------------------------------------------------------
# GROUP ASSIGNMENTS
# -----------------------------------------------------------------------------

variable "group_assignments" {
  description = "Map of group to permission set assignments"
  type = map(object({
    group_name     = string
    permission_set = string
    account_ids    = list(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.group_assignments :
      alltrue([for id in v.account_ids : can(regex("^[0-9]{12}$", id))])
    ])
    error_message = "Account IDs must be 12-digit numbers."
  }
}

# -----------------------------------------------------------------------------
# FEATURE FLAGS
# -----------------------------------------------------------------------------

variable "create_permissions_boundary" {
  description = "Whether to create the default permissions boundary policy"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Whether to create CloudWatch alarms and metric filters"
  type        = bool
  default     = false
}
