# Best Practices cho JIT Privileged Access

## 1. Permission Set Design

### ✅ DO: Tách biệt theo function

```
AWS - EC2 Admin          → AmazonEC2FullAccess
AWS - S3 Admin           → AmazonS3FullAccess  
AWS - Database Admin     → AmazonRDSFullAccess + AmazonDynamoDBFullAccess
AWS - Network Admin      → AmazonVPCFullAccess
```

### ❌ DON'T: Gộp chung permissions

```
AWS - Admin              → AdministratorAccess (quá rộng)
```

### ✅ DO: Sử dụng conditions

```json
{
  "Effect": "Allow",
  "Action": "*",
  "Resource": "*",
  "Condition": {
    "IpAddress": {"aws:SourceIp": ["10.0.0.0/8"]},
    "Bool": {"aws:MultiFactorAuthPresent": "true"}
  }
}
```

---

## 2. Session Duration

### Recommended Settings

| Access Type | PIM Duration | Permission Set Session | Total Window |
|-------------|--------------|------------------------|--------------|
| Emergency | 1 hour | 1 hour | ~2.5 hours |
| Production Admin | 2 hours | 1 hour | ~3.5 hours |
| Production Read | 4 hours | 2 hours | ~6.5 hours |
| Development | 8 hours | 4 hours | ~12.5 hours |

### ✅ DO: Match durations

```
PIM Activation:     2 hours
Permission Set:     1 hour  ← Shorter than PIM
```

### ❌ DON'T: Long sessions cho privileged access

```
PIM Activation:     24 hours  ← Too long
Permission Set:     12 hours  ← Too long
```

---

## 3. Approval Workflows

### Risk-based Approval Matrix

| Environment | Access Level | Approval Required |
|-------------|--------------|-------------------|
| Development | Any | No |
| Staging | Read-Only | No |
| Staging | Admin | Team Lead |
| Production | Read-Only | No |
| Production | Admin | Manager + Security |
| Production | Emergency | CISO |

### ✅ DO: Configure approvers

```
Primary Approver:    Direct Manager
Backup Approver:     Security Team
Escalation:          Auto-approve after 4 hours (optional)
```

---

## 4. Group Naming Convention

### Recommended Format

```
AWS - <Environment> - <Service/Role> - <Access Level>
```

### Examples

```
AWS - Production - EC2 - Admin
AWS - Production - EC2 - ReadOnly
AWS - Development - Full - Admin
AWS - All - Billing - ReadOnly
```

---

## 5. Monitoring & Alerting

### Required CloudWatch Alarms

```hcl
# Unusual login patterns
resource "aws_cloudwatch_metric_alarm" "unusual_logins" {
  alarm_name          = "JIT-UnusualLogins"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ConsoleLoginCount"
  namespace           = "AWS/CloudTrail"
  period              = 3600
  statistic           = "Sum"
  threshold           = 10
}
```

### Key Events to Monitor

| Event | Source | Alert Level |
|-------|--------|-------------|
| PIM Activation | Entra Audit | Info |
| Failed Activation | Entra Audit | Warning |
| Console Login | CloudTrail | Info |
| Privileged Action | CloudTrail | Warning |
| After-hours Access | CloudTrail | Warning |

---

## 6. SCIM Sync Considerations

### ✅ DO: Plan for sync delays

```
User activates PIM     → T+0
SCIM sync completes    → T+2 to T+10 mins (typical)
                       → T+40 mins (worst case, under throttling)
User can access AWS    → After sync
```

> "In most situations, group memberships are synchronized within 2–10 minutes, but can revert to the standard 40-minute interval if activity runs up against Entra PIM throttling limits." - AWS Blog

### ✅ DO: Handle throttling

- Stagger activations across users
- Avoid bulk activations (throttling occurs per 10-second period)
- Monitor Entra provisioning logs
- Initial sync is immediate, subsequent syncs every 40 minutes

---

## 7. Emergency Access (Break-Glass)

### Setup

```
Group:              AWS - Emergency Access
PIM Duration:       1 hour
Approval:           CISO (with 15-min auto-approve)
Permission Set:     AdministratorAccess
Conditions:         Corporate IP only
```

### Process

1. User requests emergency access
2. Justification required (incident ticket)
3. Auto-notify Security team
4. Access granted after approval/timeout
5. All actions logged
6. Post-incident review required

---

## 8. Audit & Compliance

### Required Logs Retention

| Log Type | Retention | Storage |
|----------|-----------|---------|
| Entra Audit | 90 days | Azure |
| CloudTrail | 1 year | S3 + Glacier |
| IAM Identity Center | 90 days | AWS |

### Quarterly Review Checklist

- [ ] Review all PIM eligible users
- [ ] Verify group memberships
- [ ] Check unused permission sets
- [ ] Audit activation patterns
- [ ] Update approval workflows
- [ ] Test emergency access

---

## 9. User Training

### Required Training Topics

1. How to request JIT access
2. When to use which permission set
3. Session timeout behavior
4. Emergency access procedures
5. Security responsibilities

### Quick Reference Card

```
REQUEST ACCESS:
1. Go to https://entra.microsoft.com
2. Identity Governance → PIM → My roles → Groups
3. Activate → Enter justification → Submit

ACCESS AWS:
1. Wait 5-10 minutes for sync
2. Go to https://myapps.microsoft.com
3. Click AWS IAM Identity Center
4. Select account and permission set
```

---

## 10. Common Mistakes to Avoid

| Mistake | Impact | Solution |
|---------|--------|----------|
| Long session durations | Extended exposure | Use 1-2 hour sessions |
| No approval for prod | Unauthorized access | Require manager approval |
| Shared accounts | No accountability | Individual accounts only |
| No MFA | Credential theft | Enforce MFA everywhere |
| No IP restrictions | Access from anywhere | Use Conditional Access |
| No monitoring | Missed incidents | Set up CloudWatch alarms |
| Permanent assignments | Defeats JIT purpose | Use eligible only |
