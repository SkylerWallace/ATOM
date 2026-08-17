# SFC scan
Start-Process cmd "/c sfc /scannow & pause"

# Windows Update
Start-Process ms-settings:windowsupdate
usoclient startinteractivescan

# MS Store Updates
Start-Process ms-windows-store://downloadsandupdates
Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod