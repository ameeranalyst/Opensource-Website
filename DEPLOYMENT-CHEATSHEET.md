# 🚀 nopCommerce Deployment Cheat Sheet

## Quick Command Reference

### 🔵 OPTION 1: Azure Deployment (Recommended for Production)

**Step 1: Create Infrastructure**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\deploy-to-azure.ps1
```

**Step 2: Build & Deploy**
```powershell
.\deploy-to-azure-build.ps1
```

**Result:** `https://nopcommerce-thesis-app.azurewebsites.net`

---

### 🟢 OPTION 2: Render Deployment (100% Free, No Credit Card)

**Step 1: Push to GitHub**
```powershell
git init
git add .
git config user.email "you@example.com"
git config user.name "Your Name"
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/nopcommerce-thesis.git
git push -u origin main
```

**Step 2: Follow Manual Setup**
```powershell
.\deploy-to-render.ps1
```

**Result:** `https://nopcommerce-thesis.onrender.com`

---

## 📊 Comparison

| Feature | Azure | Render |
|---------|-------|--------|
| Cost | Free 12mo, then $14/mo | Free forever |
| Setup Time | 5 minutes | 10 minutes (manual) |
| Performance | Better | Good enough |
| Database | SQL | PostgreSQL |
| Scaling | Auto | Manual |
| Best For | Production | Quick testing |

---

## 🔧 Essential Debugging Commands

### Azure
```powershell
# View logs
az webapp log tail -g nopcommerce-thesis-rg -n nopcommerce-thesis-app

# Restart app
az webapp restart -g nopcommerce-thesis-rg -n nopcommerce-thesis-app

# SSH into container
az webapp ssh -g nopcommerce-thesis-rg -n nopcommerce-thesis-app

# View app settings
az webapp config appsettings list -g nopcommerce-thesis-rg -n nopcommerce-thesis-app

# Update setting
az webapp config appsettings set -g nopcommerce-thesis-rg -n nopcommerce-thesis-app --settings KEY=value
```

### Render
```
1. Go to your dashboard
2. Click service name
3. View logs in real-time
4. Manual Deploy button for updates
```

---

## 📝 Update After Changes

### Azure
```powershell
git add .
git commit -m "Description of changes"
.\deploy-to-azure-build.ps1
```

### Render
```powershell
git add .
git commit -m "Description"
git push origin main
# Auto-deploys in 2-3 minutes
```

---

## 🗂️ File Structure Created

```
nopCommerce_4.90.6_Source/
├── deploy-to-azure.ps1              ← Run this FIRST
├── deploy-to-azure-build.ps1        ← Run this SECOND
├── deploy-to-render.ps1             ← For Render alternative
├── AZURE-DEPLOYMENT.md              ← Full documentation
├── DEPLOYMENT-CHEATSHEET.md         ← This file
└── src/
    └── Presentation/
        └── Nop.Web/
            └── appsettings.Production.json
```

---

## ❓ FAQ

**Q: Can I use free tier permanently on Azure?**  
A: Only the App Service is free for 12 months. Database costs ~$15/month after.

**Q: Is Render truly free?**  
A: Yes, including PostgreSQL (512MB). Spins down after 15 min inactivity.

**Q: How do I connect my domain?**  
A: Azure/Render both support custom domains (settings panel).

**Q: Can I migrate between platforms?**  
A: Yes, just push code to different remote. Database needs manual migration.

**Q: Performance on free tier?**  
A: Good for thesis testing. 100+ concurrent users OK. If overloaded, upgrade plan.

---

## 🔐 Security Checklist

- [ ] Changed default SQL password in scripts
- [ ] Changed deployment password in scripts
- [ ] Added HTTPS (automatic on Azure/Render)
- [ ] Disabled installation wizard in production
- [ ] Configured backups (Azure Portal)
- [ ] Reviewed security headers
- [ ] Set up SSL certificate

---

## 💾 Backup & Restore

### Azure
```powershell
# Backup database
az sql db export -g nopcommerce-thesis-rg -s nopcommerce-thesis-sqlserver \
  -n nopcommerce_db -u dbadmin -p YOUR_PASSWORD \
  --storage-key "KEY" --storage-uri "https://account.blob.core.windows.net/container/"
```

### Render
```
Render handles automatic backups. Access via Dashboard > Backups.
```

---

## 📱 What to Test Post-Deployment

1. ✓ Homepage loads
2. ✓ Registration works
3. ✓ Product browsing works
4. ✓ Admin login works
5. ✓ Database connectivity verified
6. ✓ Email notifications (if configured)
7. ✓ SSL certificate valid
8. ✓ Performance acceptable

---

## 🆘 Common Issues

### "Connection timeout"
```powershell
# Restart app
az webapp restart -g nopcommerce-thesis-rg -n nopcommerce-thesis-app

# Check logs
az webapp log tail -g nopcommerce-thesis-rg -n nopcommerce-thesis-app
```

### "Database connection error"
```powershell
# Verify connection string in app settings
az webapp config connection-string list -g nopcommerce-thesis-rg -n nopcommerce-thesis-app

# Check firewall rule allows your IP
az sql server firewall-rule list -g nopcommerce-thesis-rg -s nopcommerce-thesis-sqlserver
```

### "Build failed"
```powershell
# Check build logs in portal or restart deployment
az webapp deployment slot swap -g nopcommerce-thesis-rg -n nopcommerce-thesis-app
```

---

**Last Updated:** 2026-07-20  
**Status:** Production Ready for Thesis Testing
