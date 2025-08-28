Import-Module $psScriptRoot\..\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.'Revo Uninstaller'.ProgramInfo
Start-Program @program