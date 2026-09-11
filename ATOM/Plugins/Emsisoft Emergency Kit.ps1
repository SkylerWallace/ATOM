. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.'Emsisoft Emergency Kit'.ProgramInfo
Start-Program @program
