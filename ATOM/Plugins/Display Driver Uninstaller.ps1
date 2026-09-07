. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.'Display Driver Uninstaller'.ProgramInfo
Start-Program @program
