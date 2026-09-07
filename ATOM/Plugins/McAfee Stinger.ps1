. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.'McAfee Stinger'.ProgramInfo
Start-Program @program
