Import-Module $psScriptRoot\..\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.'Process Monitor'.ProgramInfo
Start-Program @program