Import-Module $psScriptRoot\..\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.BlueScreenView.ProgramInfo
Start-Program @program