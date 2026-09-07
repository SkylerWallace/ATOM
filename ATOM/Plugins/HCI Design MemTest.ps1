. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.'HCI Design MemTest'.ProgramInfo
Start-Program @program
