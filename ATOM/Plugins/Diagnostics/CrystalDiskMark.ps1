Import-Module $psScriptRoot\..\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.CrystalDiskMark.ProgramInfo
Start-Program @program