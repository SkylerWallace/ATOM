. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.'MSI Kombustor'.ProgramInfo
Start-Program @program
