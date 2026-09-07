. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.BlueScreenView.ProgramInfo
Start-Program @program
