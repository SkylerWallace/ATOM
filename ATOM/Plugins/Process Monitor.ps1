. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.'Process Monitor'.ProgramInfo
Start-Program @program
