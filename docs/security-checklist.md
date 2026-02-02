# Security Checklist

## Pre-Deployment Checklist

### Identity & Access

- [ ] MFA enforced trong Entra Conditional Access
- [ ] MFA required cho PIM activation
- [ ] Permissions boundary configured
- [ ] IP restrictions applied cho privileged access
- [ ] Session durations ≤ 2 hours cho admin access

### Permission Sets

- [ ] No wildcard (`*`) actions without conditions
- [ ] Explicit deny cho destructive actions
- [ ] Separate permission sets per function
- [ ] ReadOnly access cho audit/review

### Approval Workflows

- [ ] Production admin requires approval
- [ ] Emergency access requires CISO approval
- [ ] Approvers configured và active

### Monitoring

- [ ] CloudTrail enabled (all regions)
- [ ] CloudWatch alarms configured
- [ ] Entra audit logs retained
- [ ] Alert notifications configured

---

## Security Controls Matrix

| Control | Implementation | Verification |
|---------|----------------|--------------|
| MFA | Entra Conditional Access + PIM | Test login flow |
| IP Restriction | Permission set conditions | Test from outside network |
| Time-bound | PIM activation duration | Verify expiration |
| Least Privilege | Separate permission sets | Review IAM Access Analyzer |
| Audit | CloudTrail + Entra logs | Check log delivery |
| Approval | PIM approval workflow | Test activation |

---

## Destructive Actions to Deny

```json
{
  "Effect": "Deny",
  "Action": [
    "organizations:LeaveOrganization",
    "organizations:DeleteOrganization", 
    "account:CloseAccount",
    "iam:CreateUser",
    "iam:CreateAccessKey",
    "iam:DeleteAccountPasswordPolicy",
    "iam:UpdateAccountPasswordPolicy",
    "iam:AttachUserPolicy",
    "iam:PutUserPolicy",
    "ec2:DeleteVpc",
    "rds:DeleteDBInstance",
    "s3:DeleteBucket",
    "kms:ScheduleKeyDeletion",
    "kms:DisableKey"
  ],
  "Resource": "*"
}
```

---

## Recommended Permissions Boundary

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowMostActions",
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    },
    {
      "Sid": "DenyIAMUserCreation",
      "Effect": "Deny",
      "Action": [
        "iam:CreateUser",
        "iam:CreateAccessKey",
        "iam:CreateLoginProfile"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyOrganizationChanges",
      "Effect": "Deny",
      "Action": [
        "organizations:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyBillingChanges",
      "Effect": "Deny",
      "Action": [
        "aws-portal:Modify*",
        "account:Close*"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## Incident Response Runbook

### Suspected Compromise

1. **Immediate (< 5 mins)**
   ```bash
   # Remove user from all PIM eligible groups
   # In Entra: Identity Governance → PIM → Groups → Assignments → Remove
   ```

2. **Contain (< 15 mins)**
   ```bash
   # Revoke AWS sessions
   aws sso-admin delete-account-assignment ...
   
   # Disable user in Entra
   # Users → Select user → Edit properties → Block sign in
   ```

3. **Investigate (< 1 hour)**
   ```bash
   # Check CloudTrail
   aws cloudtrail lookup-events \
     --lookup-attributes AttributeKey=Username,AttributeValue=<user>
   
   # Check Entra audit logs
   # Entra → Audit logs → Filter by user
   ```

4. **Remediate**
   - Reset credentials
   - Review all actions taken
   - Update policies if needed
   - Document incident

---

## Compliance Mapping

| Framework | Control | Implementation |
|-----------|---------|----------------|
| SOC 2 | CC6.1 | MFA, IP restrictions |
| SOC 2 | CC6.2 | PIM approval workflow |
| SOC 2 | CC6.3 | Session time limits |
| ISO 27001 | A.9.2.3 | Privileged access management |
| ISO 27001 | A.9.4.1 | Access control policy |
| CIS AWS | 1.10 | MFA for privileged users |
| CIS AWS | 1.16 | IAM policies least privilege |
