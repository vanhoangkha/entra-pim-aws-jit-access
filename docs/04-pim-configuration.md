# Cấu hình Privileged Identity Management (PIM) cho Groups

## Enable PIM cho Security Group

1. Đăng nhập [Microsoft Entra admin center](https://entra.microsoft.com/)
2. **Groups > All groups** > chọn `AWS - Amazon EC2 Admin`
3. **Activity > Privileged Identity Management**
4. **Enable PIM for this group**

## Cấu hình PIM Settings

1. **Identity Governance > Privileged Identity Management > Groups**
2. Chọn `AWS - Amazon EC2 Admin`
3. **Manage > Settings > Member**

### Activation Settings

| Setting | Recommended Value | Description |
|---------|-------------------|-------------|
| Activation maximum duration | 1-8 hours | Thời gian user được access |
| Require justification | ✅ Yes | User phải giải thích lý do |
| Require ticket information | Optional | Link to ticket system |
| Require MFA | ✅ Yes | Bắt buộc MFA khi activate |
| Require approval | Optional | Cần approver cho sensitive access |

### Assignment Settings

| Setting | Recommended Value |
|---------|-------------------|
| Allow permanent eligible assignment | No |
| Expire eligible assignments after | 1 year |
| Allow permanent active assignment | No |
| Expire active assignments after | 1 hour |

## Add Eligible Users

1. **Manage > Assignments > Add assignments**
2. **Select role**: Member
3. **Select members**: Chọn users được phép request access
4. **Next**
5. **Assignment type**: Eligible
6. **Duration**: 1 year (hoặc theo policy)
7. **Assign**

## Cấu hình Approval Workflow (Optional)

1. **Settings > Member > Edit**
2. **Require approval to activate**: Yes
3. **Select approvers**: Chọn users/groups làm approvers
4. **Save**

## Notification Settings

Cấu hình email notifications cho:
- Activation requests
- Approvals
- Denials
- Expirations

## Ví dụ cấu hình theo Risk Level

### Low Risk (Development Access)

```
Activation duration: 8 hours
Require justification: Yes
Require MFA: Yes
Require approval: No
```

### Medium Risk (Production Read-Only)

```
Activation duration: 4 hours
Require justification: Yes
Require MFA: Yes
Require approval: No
```

### High Risk (Production Admin)

```
Activation duration: 1 hour
Require justification: Yes
Require MFA: Yes
Require approval: Yes (Manager + Security team)
```

## Audit & Monitoring

PIM tự động log:
- Activation requests
- Approvals/Denials
- Justifications
- Timestamps
- User information

Access logs tại: **Identity Governance > Privileged Identity Management > Groups > Audit history**
