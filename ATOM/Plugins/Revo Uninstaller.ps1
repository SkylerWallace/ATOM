. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.'Revo Uninstaller'.ProgramInfo
Start-Program @program
