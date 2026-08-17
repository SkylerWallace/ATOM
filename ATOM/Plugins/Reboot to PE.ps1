Import-Module $psScriptRoot\..\Functions\AtomModule.psm1 -Variable *
$boot2PE = Join-Path $dependenciesPath 'PE\Boot2PE.bat'
Start-Process cmd.exe -WindowStyle Hidden -ArgumentList '/c', ('"{0}"' -f $boot2PE)
