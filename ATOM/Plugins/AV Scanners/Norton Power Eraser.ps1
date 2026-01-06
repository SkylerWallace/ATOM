Import-Module $psScriptRoot\..\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.'Norton Power Eraser'.ProgramInfo
Start-Program @program