Import-Module $psScriptRoot\..\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.Regshot.ProgramInfo
Start-Program @program