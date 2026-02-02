# Just-in-Time Privileged Access to AWS with Microsoft Entra PIM

Implementation of Just-in-Time (JIT) privileged access to AWS using Microsoft Entra Privileged Identity Management (PIM) integrated with AWS IAM Identity Center.

## Overview

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   User Request  │────▶│   Entra PIM     │────▶│  IAM Identity   │
│   (Activate)    │     │  Group Assign   │     │     Center      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                              │                        │
                              │ SCIM Sync              │ Permission Set
                              │ (2-10 mins)            │ Assignment
                              ▼                        ▼
                        ┌─────────────────┐     ┌─────────────────┐
                        │  Security Group │────▶│   AWS Account   │
                        │  Membership     │     │     Access      │
                        └─────────────────┘     └─────────────────┘
```

## Features

- ✅ Time-bound access (1-24 hours)
- ✅ Approval workflow (optional)
- ✅ MFA enforcement
- ✅ Justification tracking
- ✅ Audit logging
- ✅ Automatic provisioning via SCIM
- ✅ Permissions boundary for privilege escalation prevention

## Prerequisites

| Component | Requirement |
|-----------|-------------|
| AWS | Organization instance of IAM Identity Center |
| Azure | Entra ID P1 or P2 licensing |
| Integration | SAML + SCIM configured |
| Terraform | >= 1.6 |

## Session Duration

| Setting | Default | Range | Notes |
|---------|---------|-------|-------|
| AWS access portal session | 8 hours | 15 mins - 90 days | Controlled by IAM Identity Center |
| Permission set session | 1 hour | 1 - 12 hours | Per permission set |
| PIM activation duration | 8 hours | 30 mins - 24 hours | Per group |

⚠️ **Important**: Active sessions are NOT terminated when PIM expires. Potential access window = PIM duration + sync delay (~10 mins) + session duration.

⚠️ **Security Best Practice**: Do not set session duration longer than needed to perform the role.

## Quick Start

1. [Configure SAML & SCIM](docs/01-saml-scim-setup.md)
2. [Create Security Groups](docs/02-security-groups.md)
3. [Configure Permission Sets](docs/03-permission-sets.md)
4. [Enable PIM for Groups](docs/04-pim-configuration.md)
5. [Test & Validate](docs/05-testing.md)

## Terraform Deployment

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

## References

### AWS Documentation
- [AWS Blog: Implementing JIT privileged access](https://aws.amazon.com/blogs/security/implementing-just-in-time-privileged-access-to-aws-with-microsoft-entra-and-aws-iam-identity-center/)
- [Configure SAML and SCIM with Microsoft Entra ID](https://docs.aws.amazon.com/singlesignon/latest/userguide/idp-microsoft-entra.html)
- [IAM Identity Center User Guide](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html)
- [Permission Set Session Duration](https://docs.aws.amazon.com/singlesignon/latest/userguide/howtosessionduration.html)
- [SCIM Automatic Provisioning](https://docs.aws.amazon.com/singlesignon/latest/userguide/provision-automatically.html)
- [Permissions Boundaries](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html)
- [IAM Security Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Troubleshooting IAM Identity Center](https://docs.aws.amazon.com/singlesignon/latest/userguide/troubleshooting.html)

### Microsoft Documentation
- [PIM for Groups](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure)
- [Entra ID SCIM Provisioning](https://learn.microsoft.com/en-us/azure/active-directory/app-provisioning/how-provisioning-works)

## Limitations

- Nested groups not supported with SCIM
- Dynamic groups supported but don't flatten nested groups
- Attribute removal in Entra doesn't sync to IAM Identity Center
- SCIM sync can take 2-40 minutes depending on load
- Multi-value attributes (multiple emails, phones) not supported
- SCIM token expires after 1 year - rotate before expiration
- Users must have First name, Last name, Username, Display name to sync
- After enabling SCIM, users can only be edited in IdP, not IAM Identity Center console
