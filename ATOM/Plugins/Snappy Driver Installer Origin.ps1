. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.'Snappy Driver Installer Origin'.ProgramInfo
Start-Program @program
