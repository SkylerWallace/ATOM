Import-Module $psScriptRoot\..\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.'Display Driver Uninstaller'.ProgramInfo
Start-Program @program