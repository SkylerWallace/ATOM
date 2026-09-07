@echo off
setlocal

set "systemPsPath=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "portablePsPath=%~dp0Programs\PowerShell Core_x64\powershell.exe"

set "atomPath=%~dp0ATOM\ATOM.ps1"
set "settingsPath=%~dp0ATOM\Config\Settings.ps1"
set "userSettingsPath=%~dp0ATOM\Config\SettingsUser.ps1"

reg query "HKLM\SYSTEM\CurrentControlSet\Control\MiniNT" >nul 2>&1
if not errorlevel 1 goto winpe

if exist "%systemPsPath%" (
    set "processPath=%systemPsPath%"
) else if exist "%portablePsPath%" (
    set "processPath=%portablePsPath%"
)

"%processPath%" -NoProfile -ExecutionPolicy Bypass -Command ^
    ". '%settingsPath%';" ^
    "if (Test-Path '%userSettingsPath%') { . '%userSettingsPath%' };" ^
    "$style = if ($atomSettings.EnableDebugMode.Value -or $userAtomSettings.EnableDebugMode.Value) { 'Normal' } else { 'Hidden' };" ^
    "Start-Process (Join-Path $PSHOME 'powershell.exe') -WindowStyle $style -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%atomPath%\"' -Verb RunAs"

exit

:winpe
if not exist "%portablePsPath%" (
    echo ATOM requires Programs\PowerShell Core_x64\powershell.exe in Windows PE.
    pause
    exit /b 1
)
"%portablePsPath%" -NoProfile -ExecutionPolicy Bypass -File "%atomPath%"
exit /b %ERRORLEVEL%
