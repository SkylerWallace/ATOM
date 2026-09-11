. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.CrystalDiskMark.ProgramInfo
Start-Program @program
