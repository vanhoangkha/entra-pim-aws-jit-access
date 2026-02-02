# Configure SAML & SCIM between Microsoft Entra ID and IAM Identity Center

## Prerequisites

- Microsoft Entra ID tenant with P1/P2 licensing
- AWS account with IAM Identity Center enabled (organization instance)

## Important Considerations (from AWS Docs)

| Consideration | Details |
|---------------|---------|
| **Attribute removal** | If attribute removed from user in Entra, it will NOT be removed in IAM Identity Center (known limitation) |
| **Nested groups** | NOT supported - only immediate members of explicitly assigned groups are provisioned |
| **Dynamic groups** | Supported, but don't flatten nested groups within dynamic groups |
| **Dynamic groups limitation** | Can't contain other dynamic groups |

## Step 1: Create Enterprise Application in Entra

1. Sign in to [Microsoft Entra admin center](https://entra.microsoft.com/) as Cloud Application Administrator
2. **Identity → Applications → Enterprise applications → New application**
3. Search `AWS IAM Identity Center`
4. Select and **Create**

## Step 1: Create Enterprise Application in Entra

1. Sign in to [Microsoft Entra admin center](https://entra.microsoft.com/) as Cloud Application Administrator
2. **Identity → Applications → Enterprise applications → New application**
3. Search `AWS IAM Identity Center`
4. Select and **Create**

## Step 2: Configure SAML

### 2.1 Get metadata from IAM Identity Center

1. Open [IAM Identity Center console](https://console.aws.amazon.com/singlesignon)
2. **Settings → Identity source → Actions → Change identity source**
3. Select **External identity provider → Next**
4. Download **IAM Identity Center SAML metadata** (XML)
5. Copy **AWS access portal sign-in URL**

### 2.2 Configure SAML in Entra

1. In Entra, select app **AWS IAM Identity Center**
2. **Single sign-on → SAML**
3. **Upload metadata file** (from step 2.1)
4. Paste **AWS access portal sign-in URL** into **Sign on URL**
5. **Save**
6. Download **Federation Metadata XML**

### 2.3 Complete configuration in IAM Identity Center

1. Return to IAM Identity Center console
2. Upload **IdP SAML metadata** (Federation Metadata XML from Entra)
3. **Next → Accept → Change identity source**

## Step 3: Configure SCIM

### 3.1 Enable automatic provisioning in IAM Identity Center

1. **Settings → Identity source → Automatic provisioning → Enable**
2. Copy:
   - **SCIM endpoint**: `https://scim.<region>.amazonaws.com/<id>/scim/v2`
   - **Access token**: (shown only once!)

### 3.2 Configure provisioning in Entra

1. In Entra app **AWS IAM Identity Center**
2. **Provisioning → Automatic**
3. **Admin Credentials**:
   - **Tenant URL**: paste SCIM endpoint
   - **Secret Token**: paste Access token
4. **Test Connection → Save**

## Verify

- IAM Identity Center: **Settings → Identity source** shows **SCIM** for Provisioning method
- Entra: **Provisioning → Overview** shows sync status

## Troubleshooting

| Issue | Solution |
|-------|----------|
| SAML assertion failed | Verify metadata files match |
| SCIM sync not working | Check access token validity (expires after 1 year) |
| Users not appearing | Verify user assigned to enterprise app |
| Attribute not syncing | Attribute removal from Entra doesn't sync (known limitation) |
