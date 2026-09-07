. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.'Notepad++'.ProgramInfo
Start-Program @program
