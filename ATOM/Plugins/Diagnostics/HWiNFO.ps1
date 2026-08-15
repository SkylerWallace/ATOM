Import-Module $psScriptRoot\..\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.HWiNFO.ProgramInfo
Start-Program @program
