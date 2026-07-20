# Creates GitHub repo and pushes current folder
$token = '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'
$repoName = 'Test-Website'
$body = @{ name = $repoName; private = $true } | ConvertTo-Json
Write-Host "Creating repo $repoName..."
try {
    $resp = Invoke-RestMethod -Uri 'https://api.github.com/user/repos' -Method Post -Headers @{ Authorization = "token $token"; 'User-Agent' = 'PS' } -Body $body -ContentType 'application/json' -ErrorAction Stop
    Write-Host "Repo created: $($resp.full_name)"
    $cloneUrl = $resp.clone_url
} catch {
    Write-Host "Create error: $($_.Exception.Message)"
    exit 1
}

# Initialize git and push
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)
if (-not (Test-Path .git)) {
    git init
    git config user.email 'ameeranalyst@local'
    git config user.name 'ameeranalyst'
}

git add .
try { git commit -m 'Initial commit for deployment' -q } catch { Write-Host 'No changes to commit' }

$pushUrl = $cloneUrl -replace 'https://', "https://ameeranalyst:$token@"
git remote remove origin 2>$null
git remote add origin $pushUrl
git branch -M main
Write-Host 'Pushing to GitHub...'
$push = git push $pushUrl main --force
if ($LASTEXITCODE -eq 0) { Write-Host "Pushed successfully: $cloneUrl" } else { Write-Host 'Push failed'; exit 1 }
