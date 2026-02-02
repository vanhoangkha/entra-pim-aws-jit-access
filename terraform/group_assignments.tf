locals {
  # Flatten group assignments to account level
  account_assignments = flatten([
    for name, assignment in var.group_assignments : [
      for account_id in assignment.account_ids : {
        key            = "${name}/${account_id}"
        name           = name
        group_name     = assignment.group_name
        permission_set = assignment.permission_set
        account_id     = account_id
      }
    ]
  ])
}

# -----------------------------------------------------------------------------
# DATA SOURCES - Lookup groups synced from Entra via SCIM
# -----------------------------------------------------------------------------

data "aws_identitystore_group" "this" {
  for_each = var.group_assignments

  identity_store_id = var.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value.group_name
    }
  }
}

# -----------------------------------------------------------------------------
# ACCOUNT ASSIGNMENTS
# -----------------------------------------------------------------------------

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = { for item in local.account_assignments : item.key => item }

  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set].arn

  principal_id   = data.aws_identitystore_group.this[each.value.name].group_id
  principal_type = "GROUP"

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"

  depends_on = [
    aws_ssoadmin_permission_set.this,
    aws_ssoadmin_managed_policy_attachment.this,
    aws_ssoadmin_permission_set_inline_policy.this
  ]
}
