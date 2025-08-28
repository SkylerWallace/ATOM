Import-Module $psScriptRoot\..\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.'CPU-Z'.ProgramInfo
Start-Program @program