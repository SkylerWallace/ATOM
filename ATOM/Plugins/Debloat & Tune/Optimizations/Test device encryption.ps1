(Get-CimInstance -Namespace 'Root\CIMv2\Security\MicrosoftVolumeEncryption' -ClassName Win32_EncryptableVolume -ErrorAction Stop |
    Where-Object DriveLetter -EQ $env:SystemDrive |
    Select-Object -ExpandProperty IsVolumeInitializedForProtection) -eq $true
