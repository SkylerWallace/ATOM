Import-Module $psScriptRoot\..\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.'Emsisoft Emergency Kit'.ProgramInfo
Start-Program @program
