$token = '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'
try {
    $r = Invoke-RestMethod -Uri 'https://api.github.com/user/repos' -Headers @{ Authorization = "token $token"; 'User-Agent'='PS' } -ErrorAction Stop
    foreach ($repo in $r) { Write-Output $repo.full_name }
} catch {
    Write-Output "ERROR:$($_.Exception.Message)"
}
