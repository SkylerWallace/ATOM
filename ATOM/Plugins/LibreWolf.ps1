. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.LibreWolf.ProgramInfo
Start-Program @program
