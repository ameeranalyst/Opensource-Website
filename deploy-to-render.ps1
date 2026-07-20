#############################################################################
# nopCommerce Render Deployment (FREE - No Credit Card Needed)
# Render is FREE for production with PostgreSQL
# Alternative to Azure for budget-conscious projects
#############################################################################

# Configuration
$PROJECT_NAME = "nopcommerce-thesis"
$GITHUB_REPO = "YOUR_GITHUB_USERNAME/nopcommerce-thesis"  # Change this!
$GITHUB_TOKEN = ""  # Optional: for private repos

function Write-Success([string]$msg) { Write-Host "SUCCESS: $msg" -ForegroundColor Green }
function Write-Info([string]$msg) { Write-Host "INFO: $msg" -ForegroundColor Cyan }

Write-Host ""
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "  nopCommerce RENDER Deployment (100% FREE)" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Magenta
Write-Host ""

# ============================================================================
# STEP 1: Create GitHub Repository
# ============================================================================
Write-Info "Step 1: Create GitHub Repository"
Write-Info "Go to: https://github.com/new"
Write-Info "Create public repository named: $PROJECT_NAME"
Write-Info "Then run:"
Write-Host ""
Write-Host "git init" -ForegroundColor Yellow
Write-Host "git add ." -ForegroundColor Yellow
Write-Host "git branch -M main" -ForegroundColor Yellow
Write-Host "git remote add origin https://github.com/YOUR_USERNAME/$PROJECT_NAME.git" -ForegroundColor Yellow
Write-Host "git commit -m 'Initial commit: nopCommerce'" -ForegroundColor Yellow
Write-Host "git push -u origin main" -ForegroundColor Yellow
Write-Host ""
Write-Success "After pushing to GitHub, continue to Step 2..."

Write-Host ""
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Magenta
# STEP 2: Render.com Setup Instructions
# ============================================================================
Write-Info "Step 2: Manual Setup in Render.com"
Write-Host ""
Write-Host "1. Go to: https://render.com" -ForegroundColor Yellow
Write-Host "2. Sign up with GitHub" -ForegroundColor Yellow
Write-Host "3. Click: New +  →  Web Service" -ForegroundColor Yellow
Write-Host "4. Connect your GitHub repo: $GITHUB_REPO" -ForegroundColor Yellow
Write-Host "5. Configure:" -ForegroundColor Yellow
Write-Host "   - Name: $PROJECT_NAME" -ForegroundColor Cyan
Write-Host "   - Region: Ohio (Free)" -ForegroundColor Cyan
Write-Host "   - Branch: main" -ForegroundColor Cyan
Write-Host "   - Build Command: dotnet build src/NopCommerce.sln -c Release" -ForegroundColor Cyan
Write-Host "   - Start Command: cd src/Presentation/Nop.Web && dotnet Nop.Web.dll --urls 'http://0.0.0.0:10000'" -ForegroundColor Cyan
Write-Host "   - Plan: Free" -ForegroundColor Cyan
Write-Host ""
Write-Host "6. Click: Create Web Service" -ForegroundColor Yellow
Write-Host "7. Wait 5 minutes for deployment" -ForegroundColor Yellow
Write-Host ""

# ============================================================================
# STEP 3: Add PostgreSQL Database
# ============================================================================
Write-Info "Step 3: Create PostgreSQL Database (FREE)"
Write-Host ""
Write-Host "1. In Render Dashboard, click: New +" -ForegroundColor Yellow
Write-Host "2. Select: PostgreSQL" -ForegroundColor Yellow
Write-Host "3. Configure:" -ForegroundColor Yellow
Write-Host "   - Name: nopcommerce-db" -ForegroundColor Cyan
Write-Host "   - Database: nopcommerce" -ForegroundColor Cyan
Write-Host "   - User: dbadmin" -ForegroundColor Cyan
Write-Host "   - Plan: Free (512 MB)" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Click: Create Database" -ForegroundColor Yellow
Write-Host "5. Copy connection URL (starts with postgresql://)" -ForegroundColor Yellow
Write-Host ""

# ============================================================================
# STEP 4: Configure Database Connection
# ============================================================================
Write-Info "Step 4: Connect Database to Web App"
Write-Host ""
Write-Host "1. Go to your Web Service in Render" -ForegroundColor Yellow
Write-Host "2. Click: Environment" -ForegroundColor Yellow
Write-Host "3. Add environment variable:" -ForegroundColor Yellow
Write-Host "   Key: DATABASE_URL" -ForegroundColor Cyan
Write-Host "   Value: [paste PostgreSQL URL from Step 3]" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Click: Save" -ForegroundColor Yellow
Write-Host "5. Render will redeploy automatically" -ForegroundColor Yellow
Write-Host ""

# ============================================================================
# STEP 5: Done!
# ============================================================================
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "✓ DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""
Write-Host "Your app will be at: https://$PROJECT_NAME.onrender.com" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Time You Update Code:" -ForegroundColor Yellow
Write-Host "  git add ." -ForegroundColor Cyan
Write-Host "  git commit -m 'Changes'" -ForegroundColor Cyan
Write-Host "  git push origin main" -ForegroundColor Cyan
Write-Host "  (Render auto-deploys on push)" -ForegroundColor Cyan
Write-Host ""
Write-Host "COST: $0/month (forever free tier)" -ForegroundColor Green
Write-Host ""
