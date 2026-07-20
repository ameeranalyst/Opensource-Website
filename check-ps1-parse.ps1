try {
    $s = Get-Content -Raw 'c:\Users\cAHz\Downloads\nopCommerce_4.90.6_Source\deploy-to-azure.ps1'
    [ScriptBlock]::Create($s) | Out-Null
    Write-Output 'PARSE_OK'
} catch {
    Write-Output "PARSE_ERROR:$($_.Exception.Message)"
    exit 1
}
