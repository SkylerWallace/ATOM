Import-Module $psScriptRoot\..\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.Rufus.ProgramInfo
Start-Program @program