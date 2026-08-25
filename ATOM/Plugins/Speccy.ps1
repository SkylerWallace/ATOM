Import-Module $psScriptRoot\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.Speccy.ProgramInfo
Start-Program @program
