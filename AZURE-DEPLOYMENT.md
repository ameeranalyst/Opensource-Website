# 🚀 nopCommerce Azure Deployment Guide

## Quick Start (3 Simple Steps)

### Step 1: Install Azure CLI
Download and install: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows

Verify installation:
```powershell
az --version
```

---

### Step 2: Run Deployment Script (Creates All Infrastructure)

Open PowerShell **as Administrator** in this folder and run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\deploy-to-azure.ps1
```

**What this does:**
- ✓ Logs into your Azure account
- ✓ Creates Resource Group
- ✓ Creates App Service (Free tier)
- ✓ Creates SQL Server
- ✓ Creates SQL Database
- ✓ Configures firewall
- ✓ Sets up Git deployment

**Output will show:**
```
Web Application URL: https://nopcommerce-thesis-app.azurewebsites.net
Git Deployment URL: [your-git-url]
SQL Server: nopcommerce-thesis-sqlserver.database.windows.net
```

---

### Step 3: Build & Deploy Code

After Step 2 completes, run:

```powershell
.\deploy-to-azure-build.ps1
```

**What this does:**
- ✓ Builds nopCommerce in Release mode
- ✓ Creates Git repository (if needed)
- ✓ Commits code
- ✓ Pushes to Azure
- ✓ Azure builds and deploys automatically

**Wait 3-5 minutes**, then visit:
```
https://nopcommerce-thesis-app.azurewebsites.net
```

---

## Customization (BEFORE Running)

Edit these scripts to customize:

### In `deploy-to-azure.ps1` (Line 14-22):
```powershell
$PROJECT_NAME = "nopcommerce-thesis"          # Change to your project name
$LOCATION = "eastus"                          # Change region if needed
$ADMIN_PASSWORD = "P@ssw0rd2024Thesis!"       # Change to strong password ⚠️
$DEPLOYMENT_PASSWORD = "Deploy@2024Thesis!"   # Change to strong password ⚠️
```

### In `deploy-to-azure-build.ps1` (Line 8-12):
```powershell
$PROJECT_NAME = "nopcommerce-thesis"          # MUST match deploy-to-azure.ps1
$DEPLOYMENT_USER = "nopcommerce"
$DEPLOYMENT_PASSWORD = "Deploy@2024Thesis!"   # MUST match deploy-to-azure.ps1
```

---

## Monitoring & Troubleshooting

### View Live Logs
```powershell
az webapp log tail -g nopcommerce-thesis-rg -n nopcommerce-thesis-app
```

### Restart App (if it crashes)
```powershell
az webapp restart -g nopcommerce-thesis-rg -n nopcommerce-thesis-app
```

### Check Deployment Status
```powershell
az webapp deployment list-publishing-profiles -g nopcommerce-thesis-rg -n nopcommerce-thesis-app
```

### SSH into App (for debugging)
```powershell
az webapp ssh -g nopcommerce-thesis-rg -n nopcommerce-thesis-app
```

---

## Cost Breakdown

| Component | Cost | Notes |
|-----------|------|-------|
| App Service (F1) | Free | First 12 months |
| SQL Database (S0) | ~$14/month | 10 GB storage, scalable |
| **Total** | **Free-$14/month** | Can downgrade to free tier DB |

---

## Redeploy After Code Changes

After modifying code locally:

```powershell
cd c:\Users\cAHz\Downloads\nopCommerce_4.90.6_Source
git add .
git commit -m "My changes"
$gitUrl = "your-git-url-from-step2"
$creds = "deployment-user:deployment-password"
git push "https://${creds}@your-git-url" master --force
```

Or simply run:
```powershell
.\deploy-to-azure-build.ps1
```

---

## Database Connection (From Outside Azure)

To connect SQL Server from SQL Server Management Studio:

```
Server: nopcommerce-thesis-sqlserver.database.windows.net,1433
Database: nopcommerce_db
Username: dbadmin
Password: [your-admin-password]
```

**Note:** You may need to add your IP to firewall:
```powershell
$myIp = (Invoke-WebRequest -Uri "https://api.ipify.org").Content
az sql server firewall-rule create `
  --resource-group nopcommerce-thesis-rg `
  --server nopcommerce-thesis-sqlserver `
  --name "MyIP" `
  --start-ip-address $myIp `
  --end-ip-address $myIp
```

---

## ⚠️ Important Security Notes

1. **Never hardcode credentials in code** - They're stored in App Settings
2. **Change default passwords** - Edit scripts before running
3. **Use Managed Identity** - Already enabled by script
4. **Enable HTTPS** - Azure does this automatically
5. **Set up backups** - Configure in Azure Portal

---

## Cleanup (Delete Everything)

```powershell
# This deletes all resources (⚠️ no recovery)
az group delete --name nopcommerce-thesis-rg
```

---

## Support

For issues:
1. Check logs: `az webapp log tail -g nopcommerce-thesis-rg -n nopcommerce-thesis-app`
2. Azure Portal: https://portal.azure.com
3. Restart app: `az webapp restart -g nopcommerce-thesis-rg -n nopcommerce-thesis-app`

---

**Created:** 2026-07-20  
**For:** nopCommerce Thesis Project  
**Status:** Production-Ready
