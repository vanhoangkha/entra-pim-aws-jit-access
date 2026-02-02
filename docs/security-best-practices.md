# Security Best Practices

## Principle of Least Privilege

### Permission Set Design

```
❌ Bad: Single "AdminAccess" for everything
✅ Good: Separate permission sets per function

AWS - EC2 Admin      → EC2 only
AWS - S3 Admin       → S3 only
AWS - Database Admin → RDS, DynamoDB only
```

### Time-bound Access

| Risk Level | Max Duration | Approval Required |
|------------|--------------|-------------------|
| Low | 8 hours | No |
| Medium | 4 hours | No |
| High | 1 hour | Yes |
| Critical | 30 mins | Yes + Manager |

## MFA Requirements

Enforce MFA tại nhiều layers:

1. **Entra ID Sign-in**: Conditional Access policy
2. **PIM Activation**: Require MFA on activation
3. **AWS Console**: Session policy conditions

## Approval Workflows

### When to Require Approval

- Production environment access
- Admin/privileged permissions
- Sensitive data access
- Cross-account access

### Approver Configuration

```
Tier 1 (Low risk):     No approval
Tier 2 (Medium risk):  Team lead approval
Tier 3 (High risk):    Manager + Security team
Tier 4 (Critical):     CISO approval
```

## Audit & Monitoring

### Required Logs

| Source | Events | Retention |
|--------|--------|-----------|
| Entra Audit Logs | PIM activations, group changes | 90 days |
| CloudTrail | AWS API calls, console logins | 1 year |
| IAM Identity Center | Permission assignments | 90 days |

### Alerting

Set up alerts cho:
- Failed PIM activations
- Unusual activation patterns
- Access outside business hours
- Multiple activations in short time

### Sample CloudWatch Alarm

```json
{
  "AlarmName": "UnusualPIMActivations",
  "MetricName": "ConsoleLoginCount",
  "Namespace": "AWS/CloudTrail",
  "Statistic": "Sum",
  "Period": 3600,
  "EvaluationPeriods": 1,
  "Threshold": 10,
  "ComparisonOperator": "GreaterThanThreshold"
}
```

## Session Management

### Recommended Durations

```
AWS Access Portal Session: 8 hours (default)
Permission Set Session:    1-2 hours (for privileged)
PIM Activation:           Match permission set session
```

### Session Termination

⚠️ Active sessions không bị terminate khi PIM expires.

Mitigation:
1. Set short permission set session duration
2. Educate users to sign out
3. Monitor for extended sessions

## Network Security

### Conditional Access

Restrict access based on:
- IP address ranges (corporate network)
- Device compliance
- Location
- Risk level

### AWS Session Policies

Add conditions to permission sets:
```json
{
  "Condition": {
    "IpAddress": {
      "aws:SourceIp": ["10.0.0.0/8", "192.168.0.0/16"]
    }
  }
}
```

## Incident Response

### Revoke Access Immediately

1. **Entra**: Remove user from PIM eligible
2. **Entra**: Remove user from security group
3. **AWS**: Revoke active sessions via IAM Identity Center
4. **AWS**: Check CloudTrail for actions taken

### Post-Incident

1. Review audit logs
2. Identify scope of access
3. Document timeline
4. Update policies if needed
