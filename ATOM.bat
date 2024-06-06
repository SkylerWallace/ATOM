@echo off

NET FILE >NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotAdmin ) else ( goto checkPowershellPath )

:checkPowershellPath
if exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" (
	powershell -Command "Start-Process -FilePath '%0' -Verb RunAs" & exit /B
) else (
	"%~d0Programs\Powershell Core_x64\powershell.exe" -Command "Start-Process -FilePath '%0' -Verb RunAs" & exit /B
)

:gotAdmin
if exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" (
	powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command "& '%~dp0ATOM\ATOM.ps1'"
) else (
	"%~d0Programs\Powershell Core_x64\powershell.exe" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command "& '%~dp0ATOM\ATOM.ps1'"
)