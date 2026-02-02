# Cấu hình Permission Sets trong IAM Identity Center

Permission sets định nghĩa quyền truy cập AWS cho mỗi security group.

## Tạo Permission Set

1. Mở [IAM Identity Center console](https://console.aws.amazon.com/singlesignon)
2. **Multi-account permissions > Permission sets > Create permission set**

### Option 1: Predefined permission set

Sử dụng AWS managed policies:
- **AdministratorAccess**
- **PowerUserAccess**
- **ViewOnlyAccess**
- **ReadOnlyAccess**

### Option 2: Custom permission set

1. Chọn **Custom permission set > Next**
2. Chọn policies:
   - **AWS managed policies**: e.g., `AmazonEC2FullAccess`
   - **Customer managed policies**: policies bạn tạo
   - **Inline policy**: JSON policy trực tiếp

### Ví dụ: EC2AdminAccess

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*"
            ],
            "Resource": "*"
        }
    ]
}
```

3. **Permission set name**: `EC2AdminAccess`
4. **Session duration**: `1 hour` (recommend cho JIT)
5. **Create**

## Assign Group to Permission Set

1. **Multi-account permissions > AWS accounts**
2. Chọn target account(s)
3. **Assign users or groups**
4. Chọn tab **Groups** > chọn `AWS - Amazon EC2 Admin`
5. **Next**
6. Chọn permission set `EC2AdminAccess`
7. **Submit**

## Session Duration Recommendations

| Use Case | Duration | Rationale |
|----------|----------|-----------|
| Emergency access | 1 hour | Minimize exposure |
| Regular admin tasks | 2-4 hours | Balance convenience/security |
| Long-running tasks | 8 hours | For extended operations |

## Permission Set Examples

| Permission Set | AWS Managed Policy | Use Case |
|----------------|-------------------|----------|
| `AdminAccess` | AdministratorAccess | Full admin |
| `EC2Admin` | AmazonEC2FullAccess | EC2 management |
| `S3Admin` | AmazonS3FullAccess | S3 management |
| `RDSAdmin` | AmazonRDSFullAccess | Database admin |
| `ReadOnly` | ReadOnlyAccess | Audit/review |
| `BillingView` | AWSBillingReadOnlyAccess | Cost review |

## Best Practices

1. **Least privilege**: Chỉ grant permissions cần thiết
2. **Short sessions**: Sử dụng session duration ngắn cho privileged access (AWS recommends: không longer than needed)
3. **Separate permission sets**: Tách biệt theo function, không gộp chung
4. **Naming convention**: Consistent naming giúp audit dễ dàng
5. **Permissions boundary**: Sử dụng boundary để limit maximum permissions
6. **MFA enforcement**: Require MFA cho tất cả privileged access

## Session Duration Notes

- Default: 1 hour
- Minimum: 1 hour
- Maximum: 12 hours
- IAM Identity Center tự động tạo IAM roles với max session 12 hours
- Khi update session duration, tất cả accounts sử dụng permission set sẽ được reprovision
