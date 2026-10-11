manage-bde $env:SystemDrive -Off
if ($LASTEXITCODE -ne 0) { throw "manage-bde failed with exit code $LASTEXITCODE" }
Write-Host '- Disabling Device Encryption'
