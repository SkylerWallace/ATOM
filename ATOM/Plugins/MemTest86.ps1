. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.MemTest86.ProgramInfo
Start-Program @program
