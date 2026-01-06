Import-Module $psScriptRoot\..\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.'O&O Shutup10++'.ProgramInfo
Start-Program @program