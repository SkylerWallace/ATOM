# Compatibility entry point for external WPF plugins.
. "$PSScriptRoot/Import-Atom.ps1" -Feature Wpf
Export-ModuleMember -Function * -Variable *
