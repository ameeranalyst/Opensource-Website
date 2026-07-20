$file = Get-ChildItem 'C:\Program Files' -Recurse -ErrorAction SilentlyContinue -Filter 'az.cmd' -File | Select-Object -First 1
if ($file) {
    $dir = $file.DirectoryName
    Write-Output "FOUND:$dir"
    $env:PATH = $env:PATH + ";$dir"
    az --version
} else {
    Write-Output "NOT_FOUND"
}
