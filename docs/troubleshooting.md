# Troubleshooting Guide

## Debug SAML Assertions (from AWS Docs)

To view SAML assertion details:
1. Sign in to the AWS access portal
2. Hold **Shift** key, click the application tile, release Shift
3. View "You are now in administrator mode" page
4. Choose **Copy XML** to save assertion for analysis
5. Choose **Send to <application>** to continue

> Note: Tested on Windows 10 with Firefox, Chrome, and Edge browsers.

## Common Issues

### 1. User không thấy Permission Set sau khi activate PIM

**Symptoms:**
- PIM activation thành công
- AWS access portal không hiển thị permission set

**Causes & Solutions:**

| Cause | Solution |
|-------|----------|
| SCIM chưa sync | Đợi 10-40 phút |
| Group chưa assigned to app | Assign group trong Entra enterprise app |
| Permission set chưa assigned | Assign group to account trong IAM Identity Center |

**Debug:**
```bash
# Check group exists in IAM Identity Center
aws identitystore list-groups \
  --identity-store-id d-xxxxxxxxxx \
  --query "Groups[?DisplayName=='AWS - EC2 Admin']"

# Check group membership
aws identitystore list-group-memberships \
  --identity-store-id d-xxxxxxxxxx \
  --group-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

---

### 2. SAML Authentication Failed

**Symptoms:**
- Error khi redirect từ Entra tới AWS
- "SAML response is invalid" error

**Solutions:**

1. **Verify metadata files:**
   - Re-download metadata từ cả hai phía
   - Re-upload và save

2. **Check certificate expiry:**
   ```bash
   # In Entra: Enterprise app → Single sign-on → SAML Certificates
   # Verify "Expiration Date"
   ```

3. **Verify URLs match:**
   - Identifier (Entity ID)
   - Reply URL (ACS URL)
   - Sign-on URL

4. **Debug SAML assertion:**
   - Sign in to AWS access portal
   - Hold **Shift** key, click application tile
   - View SAML assertion details
   - Choose "Copy XML" to save for analysis

---

### 3. SCIM Provisioning Failed

**Symptoms:**
- Users/groups không sync
- Provisioning errors trong Entra

**Debug trong Entra:**
1. Enterprise app → Provisioning → Provisioning logs
2. Check error messages

**Common Errors:**

| Error | Cause | Solution |
|-------|-------|----------|
| 401 Unauthorized | Token expired/invalid | Regenerate SCIM token |
| 400 Bad Request | Attribute mapping issue | Check attribute mappings |
| "name.givenName failed" | Missing first/last name | Add required user attributes |
| "List attribute emails exceeds limit" | Multi-value attributes | Send only single value per attribute |
| Timeout | Too many users | Reduce batch size, retry |

**Required User Attributes for SCIM:**
- First name (givenName)
- Last name (familyName)
- Username
- Display name

**Regenerate SCIM Token:**
1. IAM Identity Center → Settings → Identity source
2. Automatic provisioning → Regenerate token
3. Update token trong Entra

**SCIM Token Expiry:**
- Tokens valid for 1 year
- AWS sends reminders at 90 days before expiry
- Rotate before expiration to avoid sync disruption

---

### 4. User vẫn có access sau PIM expires

**Explanation:**
- Active AWS sessions không bị terminate
- Session tiếp tục cho đến khi permission set session expires

**Timeline:**
```
PIM expires at T+0
SCIM removes from group at T+10 mins
AWS session continues until T+60 mins (if 1hr session)
```

**Mitigation:**
- Set short permission set session duration
- Educate users to sign out
- Use AWS session revocation for emergencies

**Emergency Revocation:**
```bash
# Revoke all sessions for a user
aws sso-admin delete-account-assignment \
  --instance-arn arn:aws:sso:::instance/ssoins-xxx \
  --target-id 111111111111 \
  --target-type AWS_ACCOUNT \
  --permission-set-arn arn:aws:sso:::permissionSet/ssoins-xxx/ps-xxx \
  --principal-type USER \
  --principal-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

---

### 5. Nested Groups không hoạt động

**Explanation:**
- Entra SCIM không hỗ trợ nested groups
- Chỉ direct members được sync

**Solution:**
- Flatten group structure
- Assign users trực tiếp vào PIM-enabled groups
- Hoặc sử dụng Dynamic groups (với limitations)

---

### 6. Attribute không sync

**Symptoms:**
- User attributes trong IAM Identity Center không match Entra

**Known Limitation:**
- Attribute removal trong Entra KHÔNG sync tới IAM Identity Center
- Chỉ attribute changes (non-empty values) được sync
- Multi-value attributes không được hỗ trợ

**Workaround:**
- Manually update trong IAM Identity Center
- Hoặc delete và re-provision user

---

### 7. Duplicate User/Group Error

**Symptoms:**
- SCIM sync fails với duplicate error

**Solution:**
- Ensure username is unique across IdP
- Use single attribute for matching (username only)
- Check for existing users in IAM Identity Center with same username

---

## Diagnostic Commands

### Check IAM Identity Center Status

```bash
# List instances
aws sso-admin list-instances

# List permission sets
aws sso-admin list-permission-sets \
  --instance-arn arn:aws:sso:::instance/ssoins-xxx

# List account assignments
aws sso-admin list-account-assignments \
  --instance-arn arn:aws:sso:::instance/ssoins-xxx \
  --account-id 111111111111 \
  --permission-set-arn arn:aws:sso:::permissionSet/ssoins-xxx/ps-xxx
```

### Check Identity Store

```bash
# List users
aws identitystore list-users \
  --identity-store-id d-xxxxxxxxxx

# List groups
aws identitystore list-groups \
  --identity-store-id d-xxxxxxxxxx

# Get user details
aws identitystore describe-user \
  --identity-store-id d-xxxxxxxxxx \
  --user-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### Check CloudTrail for Login Events

```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=ConsoleLogin \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z
```

### Check SCIM API Calls in CloudTrail

```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventSource,AttributeValue=sso-directory.amazonaws.com \
  --start-time 2024-01-01T00:00:00Z
```

---

## Support Contacts

| Issue Type | Contact |
|------------|---------|
| Entra/PIM | Microsoft Support |
| IAM Identity Center | AWS Support |
| SCIM Sync | Both (depends on error) |
| Permission Issues | Internal Security Team |

## References

- [IAM Identity Center Troubleshooting](https://docs.aws.amazon.com/singlesignon/latest/userguide/troubleshooting.html)
- [SCIM Implementation Guide](https://docs.aws.amazon.com/singlesignon/latest/developerguide/what-is-scim.html)
- [CloudTrail SCIM Logging](https://docs.aws.amazon.com/singlesignon/latest/userguide/scim-logging-using-cloudtrail.html)
