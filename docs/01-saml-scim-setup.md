# Cấu hình SAML & SCIM giữa Microsoft Entra ID và IAM Identity Center

## Prerequisites

- Microsoft Entra ID tenant với P1/P2 licensing
- AWS account với IAM Identity Center enabled (organization instance)

## Step 1: Cài đặt Enterprise Application trong Entra

1. Đăng nhập [Microsoft Entra admin center](https://entra.microsoft.com/)
2. **Identity > Applications > Enterprise applications > New application**
3. Search `AWS IAM Identity Center`
4. Chọn và **Create**

## Step 2: Cấu hình SAML

### 2.1 Lấy metadata từ IAM Identity Center

1. Mở [IAM Identity Center console](https://console.aws.amazon.com/singlesignon)
2. **Settings > Identity source > Actions > Change identity source**
3. Chọn **External identity provider > Next**
4. Download **metadata file** (XML)
5. Copy **AWS access portal sign-in URL**

### 2.2 Cấu hình SAML trong Entra

1. Trong Entra, chọn app **AWS IAM Identity Center**
2. **Single sign-on > SAML**
3. **Upload metadata file** (từ step 2.1)
4. Paste **AWS access portal sign-in URL** vào **Sign on URL**
5. **Save**
6. Download **Federation Metadata XML**

### 2.3 Hoàn tất cấu hình trong IAM Identity Center

1. Quay lại IAM Identity Center console
2. Upload **IdP SAML metadata** (Federation Metadata XML từ Entra)
3. **Next > ACCEPT > Change identity source**

## Step 3: Cấu hình SCIM

### 3.1 Enable automatic provisioning trong IAM Identity Center

1. **Settings > Identity source > Automatic provisioning > Enable**
2. Copy:
   - **SCIM endpoint**: `https://scim.<region>.amazonaws.com/<id>/scim/v2`
   - **Access token**: (chỉ hiển thị một lần!)

### 3.2 Cấu hình provisioning trong Entra

1. Trong Entra app **AWS IAM Identity Center**
2. **Provisioning > Provisioning > Automatic**
3. **Admin Credentials**:
   - **Tenant URL**: paste SCIM endpoint
   - **Secret Token**: paste Access token
4. **Test Connection > Save**

## Verify

- IAM Identity Center: **Settings > Identity source** hiển thị **SCIM** cho Provisioning method
- Entra: **Provisioning > Overview** hiển thị sync status

## Troubleshooting

| Issue | Solution |
|-------|----------|
| SAML assertion failed | Verify metadata files match |
| SCIM sync not working | Check access token validity |
| Users not appearing | Verify user assigned to enterprise app |
