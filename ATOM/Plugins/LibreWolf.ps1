Import-Module $psScriptRoot\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.LibreWolf.ProgramInfo
Start-Program @program
