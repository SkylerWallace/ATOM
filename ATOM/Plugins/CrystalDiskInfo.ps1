. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.CrystalDiskInfo.ProgramInfo
Start-Program @program
