# -----------------------------------------------------------------------------
# PERMISSIONS BOUNDARY POLICY
# Prevents privilege escalation and destructive actions
# -----------------------------------------------------------------------------

resource "aws_iam_policy" "jit_access_boundary" {
  count = var.create_permissions_boundary ? 1 : 0

  name        = "JITAccessBoundary"
  description = "Permissions boundary for JIT access - prevents privilege escalation"
  path        = "/jit-access/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowMostActions"
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      },
      {
        Sid    = "DenyIAMPersistence"
        Effect = "Deny"
        Action = [
          "iam:CreateUser",
          "iam:CreateAccessKey",
          "iam:CreateLoginProfile",
          "iam:UpdateLoginProfile",
          "iam:AttachUserPolicy",
          "iam:PutUserPolicy",
          "iam:AddUserToGroup",
          "iam:CreateGroup",
          "iam:AttachGroupPolicy",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:UpdateAssumeRolePolicy"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyOrganizationChanges"
        Effect = "Deny"
        Action = [
          "organizations:LeaveOrganization",
          "organizations:DeleteOrganization",
          "organizations:RemoveAccountFromOrganization",
          "organizations:DeletePolicy",
          "organizations:DisablePolicyType"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyAccountChanges"
        Effect = "Deny"
        Action = [
          "account:CloseAccount",
          "account:DeleteAlternateContact",
          "billing:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenySecurityServiceDisable"
        Effect = "Deny"
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging",
          "guardduty:DeleteDetector",
          "guardduty:DisassociateFromMasterAccount",
          "securityhub:DisableSecurityHub",
          "config:DeleteConfigurationRecorder",
          "config:StopConfigurationRecorder"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyKMSKeyDeletion"
        Effect = "Deny"
        Action = [
          "kms:ScheduleKeyDeletion",
          "kms:DisableKey",
          "kms:DeleteAlias"
        ]
        Resource = "*"
      }
    ]
  })
}
