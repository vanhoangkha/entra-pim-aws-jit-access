# Create Security Groups in Microsoft Entra ID

Security groups represent privilege levels that users can request.

## Naming Convention

```
AWS - <Service/Role> <Access Level>
```

Examples:
- `AWS - Amazon EC2 Admin`
- `AWS - S3 ReadOnly`
- `AWS - Production Admin`
- `AWS - Database Admin`

## Create Security Group

1. Sign in to [Microsoft Entra admin center](https://entra.microsoft.com/)
2. **Groups → All groups → New group**
3. Configure:
   - **Group type**: Security
   - **Group name**: `AWS - Amazon EC2 Admin`
   - **Group description**: `Amazon EC2 administrator permissions`
   - **Membership type**: Assigned (required for PIM)
4. **Create**

## Assign Group to Enterprise Application

1. **Applications → Enterprise applications → AWS IAM Identity Center**
2. **Users and groups → Add user/group**
3. Select the group you created
4. **Assign**

## Start Provisioning

1. **Provisioning → Start provisioning**
2. Wait for initial sync to complete (few minutes)
3. Verify group appears in IAM Identity Center

## Important Constraints (from AWS Docs)

| Constraint | Description |
|------------|-------------|
| Membership type | Must be **Assigned**, not Dynamic (for PIM) |
| Nested groups | NOT supported - only immediate members are provisioned |
| AD-synced groups | NOT supported with PIM |
| Dynamic groups | Supported but don't flatten nested groups |

## Example Group Structure

```
AWS - Production Admin          → Full admin access to production
AWS - Production ReadOnly       → Read-only access to production
AWS - Development Admin         → Full admin access to development
AWS - Database Admin            → RDS, DynamoDB admin
AWS - Network Admin             → VPC, Route53, CloudFront admin
AWS - Security Admin            → IAM, GuardDuty, Security Hub admin
AWS - Billing ReadOnly          → Cost Explorer, Budgets read access
AWS - Emergency Access          → Break-glass admin access
```

## Verify Groups Synced to AWS

```bash
aws identitystore list-groups \
  --identity-store-id d-xxxxxxxxxx \
  --query "Groups[].DisplayName"
```
