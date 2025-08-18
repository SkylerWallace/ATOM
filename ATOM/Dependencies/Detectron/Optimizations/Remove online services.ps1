﻿$tooltip = "A specific kind of bloat that comes bundled`nwith some OEM computers"

Write-Host "Remove Online Services"

if ((Test-Path -Path "C:\Program Files\Online Services") -or (Test-Path -Path "C:\Program Files (x86)\Online Services")) {
    Remove-Item -Force -Path "C:\Program Files\Online Services" -Recurse
    Remove-Item -Force -Path "C:\Program Files (x86)\Online Services" -Recurse
    Write-Host "- Removed Online Services apps"
} else {
    Write-Host "- Online Services apps not detected"
}

$lnkFiles = @(
    "Adobe Offers.lnk",
    "Amazon.com.lnk",
    "Booking.com.lnk",
    "LastPass.lnk"
)

foreach ($lnkFile in $lnkFiles) {
    $lnkPath = Join-Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\" $lnkFile
    if (Test-Path -Path $lnkPath) {
        Remove-Item -Path $lnkPath -Force
        Write-Host "- Removed $lnkFile."
    }
}

Write-Host ""