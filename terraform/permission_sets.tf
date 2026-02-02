locals {
  # Flatten managed policy attachments
  managed_policy_attachments = flatten([
    for ps_name, ps in var.permission_sets : [
      for policy_arn in ps.managed_policies : {
        key        = "${ps_name}/${replace(policy_arn, "/", "_")}"
        ps_name    = ps_name
        policy_arn = policy_arn
      }
    ]
  ])

  # Filter permission sets with inline policies
  inline_policy_sets = {
    for name, ps in var.permission_sets : name => ps
    if ps.inline_policy != ""
  }

  # Determine which permission sets get boundary
  boundary_enabled = var.permissions_boundary_arn != null || var.create_permissions_boundary
}

# -----------------------------------------------------------------------------
# PERMISSION SETS
# -----------------------------------------------------------------------------

resource "aws_ssoadmin_permission_set" "this" {
  for_each = var.permission_sets

  name             = each.key
  description      = each.value.description
  instance_arn     = var.instance_arn
  session_duration = each.value.session_duration
  relay_state      = each.value.relay_state != "" ? each.value.relay_state : null
}

# -----------------------------------------------------------------------------
# PERMISSIONS BOUNDARY
# -----------------------------------------------------------------------------

resource "aws_ssoadmin_permissions_boundary_attachment" "this" {
  for_each = local.boundary_enabled ? var.permission_sets : {}

  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn

  permissions_boundary {
    managed_policy_arn = coalesce(
      var.permissions_boundary_arn,
      var.create_permissions_boundary ? aws_iam_policy.jit_access_boundary[0].arn : null
    )
  }

  depends_on = [aws_iam_policy.jit_access_boundary]
}

# -----------------------------------------------------------------------------
# MANAGED POLICY ATTACHMENTS
# -----------------------------------------------------------------------------

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = { for item in local.managed_policy_attachments : item.key => item }

  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.ps_name].arn
  managed_policy_arn = each.value.policy_arn

  depends_on = [aws_ssoadmin_permission_set.this]
}

# -----------------------------------------------------------------------------
# INLINE POLICY ATTACHMENTS
# -----------------------------------------------------------------------------

resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each = local.inline_policy_sets

  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  inline_policy      = each.value.inline_policy

  depends_on = [aws_ssoadmin_permission_set.this]
}
