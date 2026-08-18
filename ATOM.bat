@echo off
setlocal

set "systemPsPath=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "portablePsPath=%~d0Programs\Powershell Core_x64\powershell.exe"

set "atomPath=%~dp0ATOM\ATOM.ps1"
set "settingsPath=%~dp0ATOM\Config\Settings.ps1"
set "userSettingsPath=%~dp0ATOM\Config\SettingsUser.ps1"

if exist "%systemPsPath%" (
    set "processPath=%systemPsPath%"
) else if exist "%portablePsPath%" (
    set "processPath=%portablePsPath%"
)

"%processPath%" -NoProfile -ExecutionPolicy Bypass -Command ^
    ". '%settingsPath%';" ^
    "if (Test-Path '%userSettingsPath%') { . '%userSettingsPath%' };" ^
    "$style = if ($atomSettings.EnableDebugMode.Value -or $userAtomSettings.EnableDebugMode.Value) { 'Normal' } else { 'Hidden' };" ^
    "Start-Process powershell -WindowStyle $style -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%atomPath%\"' -Verb RunAs"

exit