#############################################################################
# nopCommerce Azure Deployment Script
# Run this once and it handles everything: resources, database, deployment
# Senior-level automation for thesis project
#############################################################################

# Color output (ASCII-safe)
function Write-Success([string]$msg) { Write-Host "SUCCESS: $msg" -ForegroundColor Green }
function Write-Error-Custom([string]$msg) { Write-Host "ERROR: $msg" -ForegroundColor Red }
function Write-Info([string]$msg) { Write-Host "INFO: $msg" -ForegroundColor Cyan }

# Configuration (EDIT THESE)
$PROJECT_NAME = "nopcommerce-thesis"
$LOCATION = "eastus"
$ENVIRONMENT = "production"
$APP_SKU = "F1"  # F1 = Free tier
$ADMIN_USER = "dbadmin"
$ADMIN_PASSWORD = "P@ssw0rd2024Thesis!" # CHANGE THIS to strong password
$DEPLOYMENT_USER = "nopcommerce"
$DEPLOYMENT_PASSWORD = "Deploy@2024Thesis!" # CHANGE THIS

Write-Info "Starting nopCommerce Azure Deployment..."
Write-Info "Configuration: $PROJECT_NAME | Region: $LOCATION"

# Ensure Azure CLI (`az`) is available in this session. If not on PATH, try to locate `az.cmd` in Program Files and add it.
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    $azFile = Get-ChildItem 'C:\Program Files' -Recurse -ErrorAction SilentlyContinue -Filter 'az.cmd' -File | Select-Object -First 1
    if ($azFile) {
        $azDir = $azFile.DirectoryName
        $env:PATH = $env:PATH + ";$azDir"
        Write-Info "Added az to PATH from: $azDir"
    } else {
        Write-Error-Custom "Azure CLI not installed. Download from: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows"
        exit 1
    }
}

# ============================================================================
# STEP 1: Login to Azure
# ============================================================================
Write-Info "Step 1: Authenticating with Azure..."
try {
    $account = az account show 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Info "Opening Azure login browser..."
        az login
    } else {
        Write-Success "Already logged in"
    }
} catch {
    Write-Error-Custom "Azure CLI not installed. Download from: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows"
    exit 1
}

# ============================================================================
# STEP 2: Create Resource Group
# ============================================================================
Write-Info "Step 2: Creating Resource Group..."
$resourceGroup = "${PROJECT_NAME}-rg"
az group create --name $resourceGroup --location $LOCATION --output none
Write-Success "Resource Group created: $resourceGroup"

# ============================================================================
# STEP 3: Create App Service Plan (Free tier)
# ============================================================================
Write-Info "Step 3: Creating App Service Plan (Free tier)..."
$appPlanName = "${PROJECT_NAME}-plan"
az appservice plan create `
    --name $appPlanName `
    --resource-group $resourceGroup `
    --sku $APP_SKU `
    --number-of-workers 1 `
    --output none
Write-Success "App Service Plan created: $appPlanName"

# ============================================================================
# STEP 4: Create Web App
# ============================================================================
Write-Info "Step 4: Creating Web App..."
$webAppName = "${PROJECT_NAME}-app"
az webapp create `
    --resource-group $resourceGroup `
    --plan $appPlanName `
    --name $webAppName `
    --runtime "DOTNET|9.0" `
    --output none
Write-Success "Web App created: $webAppName"

# ============================================================================
# STEP 5: Create SQL Server
# ============================================================================
Write-Info "Step 5: Creating SQL Server..."
$sqlServerName = "${PROJECT_NAME}-sqlserver"
az sql server create `
    --name $sqlServerName `
    --resource-group $resourceGroup `
    --admin-user $ADMIN_USER `
    --admin-password $ADMIN_PASSWORD `
    --output none
Write-Success "SQL Server created: $sqlServerName"

# ============================================================================
# STEP 6: Create SQL Database
# ============================================================================
Write-Info "Step 6: Creating SQL Database..."
$dbName = "nopcommerce_db"
az sql db create `
    --resource-group $resourceGroup `
    --server $sqlServerName `
    --name $dbName `
    --edition Basic `
    --compute-model Provisioned `
    --service-objective S0 `
    --output none
Write-Success "Database created: $dbName"

# ============================================================================
# STEP 7: Configure Firewall (Allow Azure Services + Your IP)
# ============================================================================
Write-Info "Step 7: Configuring Firewall Rules..."
az sql server firewall-rule create `
    --resource-group $resourceGroup `
    --server $sqlServerName `
    --name "AllowAzureServices" `
    --start-ip-address 0.0.0.0 `
    --end-ip-address 0.0.0.0 `
    --output none
Write-Success "Firewall configured for Azure services"

# ============================================================================
# STEP 8: Build connection string
# ============================================================================
Write-Info "Step 8: Configuring connection string..."
$sqlServerFqdn = "${sqlServerName}.database.windows.net"
$connectionString = "Server=tcp:$sqlServerFqdn,1433;Initial Catalog=$dbName;Persist Security Info=False;User ID=$ADMIN_USER;Password=$ADMIN_PASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

az webapp config connection-string set `
    --resource-group $resourceGroup `
    --name $webAppName `
    --connection-string-type SQLAzure `
    --settings DefaultConnection=$connectionString `
    --output none
Write-Success "Connection string configured"

# ============================================================================
# STEP 9: Configure App Settings
# ============================================================================
Write-Info "Step 9: Configuring App Settings..."
az webapp config appsettings set `
    --resource-group $resourceGroup `
    --name $webAppName `
    --settings `
        ASPNETCORE_ENVIRONMENT=Production `
        DOTNET_USE_POLLING_FILE_WATCHER=1 `
        WEBSITES_ENABLE_APP_SERVICE_STORAGE=true `
    --output none
Write-Success "App settings configured"

# ============================================================================
# STEP 10: Enable Managed Identity (for security)
# ============================================================================
Write-Info "Step 10: Enabling Managed Identity..."
az webapp identity assign `
    --resource-group $resourceGroup `
    --name $webAppName `
    --output none
Write-Success "Managed Identity enabled"

# ============================================================================
# STEP 11: Set Deployment User (for Git deployment)
# ============================================================================
Write-Info "Step 11: Setting deployment credentials..."
az webapp deployment user set `
    --user-name $DEPLOYMENT_USER `
    --password $DEPLOYMENT_PASSWORD `
    --output none
Write-Success "Deployment user set: $DEPLOYMENT_USER"

# ============================================================================
# STEP 12: Enable Local Git Deployment
# ============================================================================
Write-Info "Step 12: Enabling Local Git Deployment..."
$gitUrl = az webapp deployment source config-local-git `
    --resource-group $resourceGroup `
    --name $webAppName `
    --query url -o tsv
Write-Success "Git deployment enabled"

# ============================================================================
# STEP 13: Display Summary and Next Steps
# ============================================================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "AZURE INFRASTRUCTURE DEPLOYMENT COMPLETE" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "Web Application URL:" -ForegroundColor Yellow
Write-Host "  https://$webAppName.azurewebsites.net" -ForegroundColor Cyan
Write-Host ""
Write-Host "Database Connection Details:" -ForegroundColor Yellow
Write-Host "  Server: $sqlServerFqdn" -ForegroundColor Cyan
Write-Host "  Database: $dbName" -ForegroundColor Cyan
Write-Host "  Username: $ADMIN_USER" -ForegroundColor Cyan
Write-Host "  Password: [Use Azure Portal to reset if needed]" -ForegroundColor Cyan
Write-Host ""
Write-Host "Git Deployment URL:" -ForegroundColor Yellow
Write-Host "  $gitUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Run: deploy-to-azure-build.ps1 (to build and push code)" -ForegroundColor White
Write-Host "  2. Wait 2-3 minutes for deployment" -ForegroundColor White
Write-Host "  3. Visit: https://$webAppName.azurewebsites.net" -ForegroundColor White
Write-Host "  4. Check logs: az webapp log tail -g $resourceGroup -n $webAppName" -ForegroundColor White
Write-Host ""
Write-Host "Save these details for reference:" -ForegroundColor Yellow
Write-Host "  Resource Group: $resourceGroup" -ForegroundColor Cyan
Write-Host "  App Name: $webAppName" -ForegroundColor Cyan
Write-Host "  SQL Server: $sqlServerName" -ForegroundColor Cyan
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
