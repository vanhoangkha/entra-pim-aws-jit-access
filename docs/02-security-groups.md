# Tạo Security Groups trong Microsoft Entra ID

Security groups đại diện cho các privilege levels mà users có thể request.

## Naming Convention

```
AWS - <Service/Role> <Access Level>
```

Ví dụ:
- `AWS - Amazon EC2 Admin`
- `AWS - S3 ReadOnly`
- `AWS - Production Admin`
- `AWS - Database Admin`

## Tạo Security Group

1. Đăng nhập [Microsoft Entra admin center](https://entra.microsoft.com/)
2. **Groups > All groups > New group**
3. Cấu hình:
   - **Group type**: Security
   - **Group name**: `AWS - Amazon EC2 Admin`
   - **Group description**: `Amazon EC2 administrator permissions`
   - **Membership type**: Assigned (bắt buộc cho PIM)
4. **Create**

## Assign Group to Enterprise Application

1. **Applications > Enterprise applications > AWS IAM Identity Center**
2. **Users and groups > Add user/group**
3. Chọn group vừa tạo
4. **Assign**

## Start Provisioning

1. **Provisioning > Start provisioning**
2. Đợi initial sync hoàn tất (vài phút)
3. Verify group xuất hiện trong IAM Identity Center

## Lưu ý quan trọng

| Constraint | Description |
|------------|-------------|
| Membership type | Phải là **Assigned**, không phải Dynamic |
| Nested groups | Không được hỗ trợ với PIM |
| AD-synced groups | Không được hỗ trợ với PIM |

## Ví dụ cấu trúc Groups

```
AWS - Production Admin          → Full admin access to production
AWS - Production ReadOnly       → Read-only access to production
AWS - Development Admin         → Full admin access to development
AWS - Database Admin            → RDS, DynamoDB admin
AWS - Network Admin             → VPC, Route53, CloudFront admin
AWS - Security Admin            → IAM, GuardDuty, Security Hub admin
AWS - Billing ReadOnly          → Cost Explorer, Budgets read access
```
