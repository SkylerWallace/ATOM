Import-Module $psScriptRoot\..\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.CrystalDiskInfo.ProgramInfo
Start-Program @program