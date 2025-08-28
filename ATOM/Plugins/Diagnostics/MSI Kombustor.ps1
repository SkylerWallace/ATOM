Import-Module $psScriptRoot\..\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.'MSI Kombustor'.ProgramInfo
Start-Program @program