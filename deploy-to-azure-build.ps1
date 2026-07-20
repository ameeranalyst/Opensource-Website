#############################################################################
# nopCommerce Build & Deploy to Azure Script
# Run this AFTER deploy-to-azure.ps1 completes
# Builds the project and pushes to Azure via Git
#############################################################################

# Configuration (MATCH with deploy-to-azure.ps1)
$PROJECT_NAME = "nopcommerce-thesis"
$DEPLOYMENT_USER = "nopcommerce"
$DEPLOYMENT_PASSWORD = "Deploy@2024Thesis!"
$webAppName = "${PROJECT_NAME}-app"
$resourceGroup = "${PROJECT_NAME}-rg"

# Color output
function Write-Success([string]$msg) { Write-Host "SUCCESS: $msg" -ForegroundColor Green }
function Write-Error-Custom([string]$msg) { Write-Host "ERROR: $msg" -ForegroundColor Red }
function Write-Info([string]$msg) { Write-Host "INFO: $msg" -ForegroundColor Cyan }

$solutionRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Info "Starting Build & Deployment to Azure..."
Write-Info "Solution: $solutionRoot"

# ============================================================================
# STEP 1: Get Git Deployment URL
# ============================================================================
Write-Info "Step 1: Getting Git deployment URL..."
try {
    $gitUrl = az webapp deployment source config-local-git `
        --resource-group $resourceGroup `
        --name $webAppName `
        --query url -o tsv
    Write-Success "Git URL obtained"
} catch {
    Write-Error-Custom "Failed to get Git URL. Run deploy-to-azure.ps1 first."
    exit 1
}

# ============================================================================
# STEP 2: Initialize Git (if not already done)
# ============================================================================
Write-Info "Step 2: Setting up Git repository..."
cd $solutionRoot

if (-not (Test-Path ".git")) {
    Write-Info "Initializing Git repository..."
    git init
    git config user.email "thesis@local.dev"
    git config user.name "Thesis Deployer"
    Write-Success "Git repository initialized"
} else {
    Write-Success "Git repository already exists"
}

# ============================================================================
# STEP 3: Create .gitignore if it doesn't exist
# ============================================================================
Write-Info "Step 3: Configuring .gitignore..."
if (-not (Test-Path ".gitignore")) {
    Write-Info "Creating .gitignore..."
    @"
# Build results
[Dd]ebug/
[Dd]ebugPublic/
[Rr]elease/
[Rr]eleases/
x64/
x86/
[Ww][Ii][Nn]32/
[Aa][Rr][Mm]/
[Aa][Rr][Mm]64/
bld/
[Bb]in/
[Oo]bj/
[Ll]og/
[Ll]ogs/

# Visual Studio cache/options
.vs/
.vscode/

# User-specific files
*.rsuser
*.suo
*.user
*.userosscache
*.sln.docstates

# Local history
.history/
.localhistory/

# NuGet
*.nupkg
.nuget/

# App_Data (runtime generated)
src/Presentation/Nop.Web/App_Data/

# Node modules
node_modules/
npm-debug.log
yarn-error.log

# OS
.DS_Store
Thumbs.db

# Misc
*.log
*.tmp
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8 -Force
    Write-Success ".gitignore created"
} else {
    Write-Success ".gitignore already exists"
}

# ============================================================================
# STEP 4: Build the solution
# ============================================================================
Write-Info "Step 4: Building nopCommerce (Release)..."
Write-Info "This may take 2-3 minutes, please wait..."

$localDotnet = "$solutionRoot\dotnet\dotnet.exe"
if (Test-Path $localDotnet) {
    Write-Info "Using local .NET SDK..."
    & $localDotnet build "$solutionRoot\src\NopCommerce.sln" -c Release
} else {
    Write-Info "Using global .NET SDK..."
    dotnet build "$solutionRoot\src\NopCommerce.sln" -c Release
}

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Build failed. Check errors above."
    exit 1
}
Write-Success "Build completed successfully"

# ============================================================================
# STEP 5: Stage and commit
# ============================================================================
Write-Info "Step 5: Preparing Git commit..."
git add .
git status

Write-Info "Creating git commit..."
git commit -m "Deploy nopCommerce to Azure - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

if ($LASTEXITCODE -ne 0) {
    Write-Info "No changes to commit (that's ok if already deployed)"
}

# ============================================================================
# STEP 6: Add Azure remote
# ============================================================================
Write-Info "Step 6: Configuring Azure remote..."
git remote remove azure 2>$null
git remote add azure $gitUrl
Write-Success "Azure remote configured"

# ============================================================================
# STEP 7: Push to Azure
# ============================================================================
Write-Info "Step 7: Pushing to Azure (this will deploy)..."
Write-Info "This may take 3-5 minutes..."

# Set credentials in URL for push
$gitUrlWithCreds = $gitUrl -replace "https://", "https://$DEPLOYMENT_USER`:$DEPLOYMENT_PASSWORD@"
git push $gitUrlWithCreds master --force 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Success "Code pushed to Azure successfully!"
} else {
    # Try with main branch
    Write-Info "Trying with 'main' branch..."
    git push $gitUrlWithCreds main --force 2>$null
}

# ============================================================================
# STEP 8: Monitor Deployment
# ============================================================================
Write-Info "Step 8: Monitoring deployment..."
Write-Host ""
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "CODE PUSHED TO AZURE" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "Deployment Status:" -ForegroundColor Yellow
Write-Host "  App will be available in 3-5 minutes at:" -ForegroundColor White
Write-Host "  https://$webAppName.azurewebsites.net" -ForegroundColor Cyan
Write-Host ""
Write-Host "To monitor deployment logs in real-time, run:" -ForegroundColor Yellow
Write-Host "  az webapp log tail -g $resourceGroup -n $webAppName" -ForegroundColor Cyan
Write-Host ""
Write-Host "To restart the app:" -ForegroundColor Yellow
Write-Host "  az webapp restart -g $resourceGroup -n $webAppName" -ForegroundColor Cyan
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
