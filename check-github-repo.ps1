$token = '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'
$repo = 'ameeranalyst/Test%20Website'
try {
    $r = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo" -Headers @{ Authorization = "token $token"; 'User-Agent' = 'PS' } -ErrorAction Stop
    Write-Output "EXISTS:$($r.clone_url)"
} catch {
    Write-Output "NOT_FOUND:$($_.Exception.Message)"
}
