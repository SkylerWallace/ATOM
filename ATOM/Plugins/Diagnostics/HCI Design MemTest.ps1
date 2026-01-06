Import-Module $psScriptRoot\..\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = $programs.'HCI Design MemTest'.ProgramInfo
Start-Program @program