. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.TeraCopy.ProgramInfo
Start-Program @program
