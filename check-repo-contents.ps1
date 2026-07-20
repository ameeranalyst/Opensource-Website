$token = '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'
try {
    $r = Invoke-RestMethod -Uri 'https://api.github.com/repos/ameeranalyst/Opensource-Website/contents' -Headers @{ Authorization = "token $token"; 'User-Agent'='PS' } -ErrorAction Stop
    foreach ($item in $r) { Write-Output $item.name }
} catch {
    Write-Output "ERROR:$($_.Exception.Message)"
}
