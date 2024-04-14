::@echo off
title Boot2PE

setlocal

:: Delete remnants
powershell -ExecutionPolicy Bypass -File "%~dp0ClearBCD.ps1"

:: RAMdisk boot entry
set currentDrive=%~d0
bcdedit /create {ramdiskoptions} /d "ATOM PE"
bcdedit /set {ramdiskoptions} ramdisksdidevice partition=%currentDrive%
bcdedit /set {ramdiskoptions} ramdisksdipath \boot\boot.sdi

:: ATOM boot entry
for /f "tokens=3" %%A in ('bcdedit /create /d "ATOM PE" /application OSLOADER') do set guid=%%A

:: Set boot entry properties
bcdedit /set %guid% device ramdisk=[%currentDrive%]\sources\boot.wim,{ramdiskoptions}
bcdedit /set %guid% path \windows\system32\winload.efi
bcdedit /set %guid% osdevice ramdisk=[%currentDrive%]\sources\boot.wim,{ramdiskoptions}
bcdedit /set %guid% systemroot \Windows
bcdedit /set %guid% winpe yes
bcdedit /set %guid% detecthal yes

:: Configuring boot sequence
bcdedit /displayorder %guid% /addlast
bcdedit /bootsequence %guid%
bcdedit /timeout 1

endlocal

shutdown /r /f /t 2
exit /b 0