@echo off

set systemPsPath="%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set portablePsPath="%~d0Programs\Powershell Core_x64\powershell.exe"

if exist %systemPsPath% (set processPath=powershell
) else if exist %portablePsPath% set processPath=%portablePsPath%

%processPath% -Command "Start-Process powershell -WindowStyle Hidden -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0ATOM\ATOM.ps1\"' -Verb RunAs"
exit