. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.'File Beholder'.ProgramInfo
Start-Program @program
