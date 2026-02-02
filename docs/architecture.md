# Architecture Overview

## Solution Architecture

```
┌────────────────────────────────────────────────────────────────────────────┐
│                              Microsoft Entra ID                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐        │
│  │      User       │───▶│   Entra PIM     │───▶│ Security Group  │        │
│  │   (Eligible)    │    │  (Activation)   │    │  (Membership)   │        │
│  └─────────────────┘    └─────────────────┘    └────────┬────────┘        │
│                                                          │                 │
│                                                    SCIM Sync               │
│                                                    (2-10 mins)             │
└──────────────────────────────────────────────────────────┼─────────────────┘
                                                           │
                                                           ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                           AWS IAM Identity Center                          │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐        │
│  │     Group       │───▶│ Permission Set  │───▶│   AWS Account   │        │
│  │  (Synced)       │    │  Assignment     │    │    Access       │        │
│  └─────────────────┘    └─────────────────┘    └────────┬────────┘        │
│                                                          │                 │
└──────────────────────────────────────────────────────────┼─────────────────┘
                                                           │
                                                           ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                              AWS Account(s)                                │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐        │
│  │    IAM Role     │───▶│   Temporary     │───▶│   AWS Console   │        │
│  │  (Assumed)      │    │  Credentials    │    │   / CLI / SDK   │        │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘        │
└────────────────────────────────────────────────────────────────────────────┘
```

## Data Flow

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  User    │     │  Entra   │     │   SCIM   │     │   IAM    │     │   AWS    │
│          │     │   PIM    │     │   Sync   │     │   IDC    │     │ Account  │
└────┬─────┘     └────┬─────┘     └────┬─────┘     └────┬─────┘     └────┬─────┘
     │                │                │                │                │
     │ 1. Request     │                │                │                │
     │   Activation   │                │                │                │
     │───────────────▶│                │                │                │
     │                │                │                │                │
     │ 2. Validate    │                │                │                │
     │   & Approve    │                │                │                │
     │◀───────────────│                │                │                │
     │                │                │                │                │
     │                │ 3. Add to      │                │                │
     │                │    Group       │                │                │
     │                │───────────────▶│                │                │
     │                │                │                │                │
     │                │                │ 4. Sync        │                │
     │                │                │    Membership  │                │
     │                │                │───────────────▶│                │
     │                │                │                │                │
     │ 5. Access      │                │                │                │
     │    Portal      │                │                │                │
     │────────────────────────────────────────────────▶│                │
     │                │                │                │                │
     │                │                │                │ 6. SAML        │
     │                │                │                │    Assertion   │
     │                │                │                │───────────────▶│
     │                │                │                │                │
     │ 7. Assume Role │                │                │                │
     │◀───────────────────────────────────────────────────────────────────│
     │                │                │                │                │
```

## Session Timeline

```
Time ─────────────────────────────────────────────────────────────────────────▶

     │◀─── PIM Activation Duration (1-8 hours) ───▶│
     │                                              │
     │    │◀─ SCIM Sync ─▶│                        │◀─ SCIM Sync ─▶│
     │    │   (2-10 min)  │                        │   (2-10 min)  │
     │    │               │                        │               │
─────┼────┼───────────────┼────────────────────────┼───────────────┼──────────
     │    │               │                        │               │
  Activate │            Access                   Expire          Access
  Request  │            Granted                  PIM             Revoked
           │                                                      
           │◀──────── Permission Set Session (1-12 hours) ───────▶│
           │                                                       │
           │                                                       │
        Session                                                 Session
        Start                                                   End
```

## Components

| Component | Role | Location |
|-----------|------|----------|
| Entra PIM | Manage eligibility & activation | Microsoft Entra ID |
| Security Groups | Map to permission sets | Microsoft Entra ID |
| SCIM | Sync users/groups | Between Entra & AWS |
| IAM Identity Center | Manage AWS access | AWS |
| Permission Sets | Define AWS permissions | AWS |
| AWS Accounts | Target resources | AWS |
