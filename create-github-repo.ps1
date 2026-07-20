$token = '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'
$attempts = @('Test Website','Test-Website')
foreach ($name in $attempts) {
    Write-Output "Trying repo name: $name"
    $body = @{ name = $name; private = $true } | ConvertTo-Json
    try {
        $resp = Invoke-RestMethod -Uri 'https://api.github.com/user/repos' -Method Post -Headers @{ Authorization = "token $token"; 'User-Agent' = 'PS' } -Body $body -ContentType 'application/json' -ErrorAction Stop
        Write-Output "CREATED:$($resp.full_name) $($resp.clone_url)"
        exit 0
    } catch {
        Write-Output "CREATE_ERROR:$($_.Exception.Message)"
    }
}
Write-Output 'FAILED_TO_CREATE'
exit 1
