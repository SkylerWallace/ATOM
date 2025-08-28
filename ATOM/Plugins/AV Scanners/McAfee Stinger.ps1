Import-Module $psScriptRoot\..\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.'McAfee Stinger'.ProgramInfo
Start-Program @program