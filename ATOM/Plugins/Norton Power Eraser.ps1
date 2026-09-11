. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.'Norton Power Eraser'.ProgramInfo
Start-Program @program
