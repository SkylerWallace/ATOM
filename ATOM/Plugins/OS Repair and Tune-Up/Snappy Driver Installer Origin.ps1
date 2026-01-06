Import-Module $psScriptRoot\..\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.'Snappy Driver Installer Origin'.ProgramInfo
Start-Program @program