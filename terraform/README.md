# Terraform Configuration for JIT Access

Terraform module để tạo Permission Sets và Group Assignments trong IAM Identity Center.

## Prerequisites

1. IAM Identity Center đã enabled
2. SAML + SCIM đã cấu hình với Microsoft Entra ID
3. Security groups đã được sync từ Entra

## Lấy thông tin cần thiết

### Identity Store ID và Instance ARN

```bash
# Sử dụng AWS CLI
aws sso-admin list-instances

# Output:
# {
#     "Instances": [
#         {
#             "InstanceArn": "arn:aws:sso:::instance/ssoins-1234567890abcdef0",
#             "IdentityStoreId": "d-1234567890"
#         }
#     ]
# }
```

Hoặc từ IAM Identity Center Console: **Settings > Identity source**

## Usage

1. Copy example tfvars:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Update values trong `terraform.tfvars`:
   - `identity_store_id`
   - `instance_arn`
   - `permission_sets`
   - `group_assignments`

3. Initialize và apply:
```bash
terraform init
terraform plan
terraform apply
```

## Session Duration Format

Sử dụng ISO 8601 duration format:
- `PT1H` = 1 hour
- `PT2H` = 2 hours
- `PT4H` = 4 hours
- `PT8H` = 8 hours
- `PT12H` = 12 hours (maximum)

## Important Notes

- Group names trong `group_assignments` phải match chính xác với tên group trong Entra
- Groups phải được sync qua SCIM trước khi chạy Terraform
- Permission set session duration nên match với PIM activation duration

## SCIM Considerations (từ AWS Docs)

### Required User Attributes

Mỗi user PHẢI có các attributes sau để sync thành công:
- **First name** (givenName)
- **Last name** (familyName)
- **Username**
- **Display name**

### Important Limitations

| Limitation | Impact |
|------------|--------|
| Multi-value attributes | Không hỗ trợ (e.g., multiple emails) |
| Nested groups | Không được sync |
| Attribute removal | Không sync từ Entra → IAM Identity Center |
| User editing | Sau khi enable SCIM, chỉ edit users trong IdP |

### SCIM Token Management

- Token valid: 1 năm
- AWS gửi reminders: 90 ngày trước khi expire
- Nếu token expire: Sync dừng hoàn toàn
- Best practice: Rotate token trước khi expire

### externalId Mapping

Map `externalId` tới một value:
- Unique
- Always present
- Least likely to change (e.g., objectId)

Điều này đảm bảo users không mất AWS entitlements khi thay đổi name/email.

## Verify Groups Synced

```bash
aws identitystore list-groups \
  --identity-store-id d-1234567890 \
  --query "Groups[].DisplayName"
```
