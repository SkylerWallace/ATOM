@echo off
start ms-settings:windowsupdate & start ms-windows-store://downloadsandupdates
sfc /scannow
pause
