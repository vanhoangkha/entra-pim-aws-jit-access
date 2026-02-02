# Testing & Validation

## Test Flow

```
1. User activates PIM membership
2. Wait for SCIM sync (2-10 mins)
3. User accesses AWS via My Apps portal
4. Verify permission set access
5. Wait for PIM expiration
6. Verify access revoked
```

## Step 1: Activate PIM Membership

1. User đăng nhập [Microsoft Entra admin center](https://entra.microsoft.com/)
2. **Identity Governance > Privileged Identity Management > My roles**
3. **Activate > Groups**
4. Chọn **Activate** cho `AWS - Amazon EC2 Admin`
5. Nhập **Justification**
6. **Activate**

## Step 2: Wait for SCIM Sync

- Typical: 2-10 minutes
- Maximum: 40 minutes (under throttling)

Verify sync trong IAM Identity Center:
1. **Users** hoặc **Groups**
2. Check group membership updated

## Step 3: Access AWS

1. Mở [My Apps portal](https://myapps.microsoft.com/)
2. Chọn **AWS IAM Identity Center** app
3. Redirect tới AWS access portal
4. Chọn account và permission set
5. **Management console**

## Step 4: Verify Access

Test các actions được phép:
```bash
# Ví dụ với EC2 Admin
aws ec2 describe-instances
aws ec2 start-instances --instance-ids i-xxx
```

Test các actions bị denied:
```bash
# Nếu chỉ có EC2 access
aws s3 ls  # Should fail
aws iam list-users  # Should fail
```

## Step 5: Verify Access Revocation

Sau khi PIM activation expires:

1. Đợi activation duration hết
2. Đợi thêm SCIM sync (2-10 mins)
3. Refresh AWS access portal
4. Permission set không còn hiển thị

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Permission set không hiển thị | SCIM chưa sync | Đợi 10-40 mins |
| Access denied sau khi activate | Group chưa assigned | Check group assignment trong Entra |
| Vẫn có access sau PIM expires | Active session | Session timeout theo permission set duration |
| SAML error | Metadata mismatch | Re-upload metadata files |

## Checklist

### Pre-deployment

- [ ] SAML connection tested
- [ ] SCIM provisioning working
- [ ] Security groups created
- [ ] Permission sets configured
- [ ] Groups assigned to accounts
- [ ] PIM enabled for groups
- [ ] Eligible users assigned

### Post-deployment

- [ ] User can activate PIM
- [ ] SCIM sync completes
- [ ] User can access AWS
- [ ] Correct permissions applied
- [ ] Access revoked after expiration
- [ ] Audit logs captured

## Monitoring

### CloudTrail Events

Monitor AWS access:
```
eventSource: signin.amazonaws.com
eventName: ConsoleLogin
userIdentity.type: SAMLUser
```

### Entra Audit Logs

Monitor PIM activities:
- `Add member to group`
- `Remove member from group`
- `PIM activation`
