# Compatibility entry point for external plugins. Built-in scripts use Import-Atom.ps1.
param ([String[]]$FunctionName)
if ($FunctionName) {
    . "$PSScriptRoot/Import-Atom.ps1" -Function $FunctionName -Feature Catalog
} else {
    . "$PSScriptRoot/Import-Atom.ps1" -Group Runtime -Feature Catalog
}
Export-ModuleMember -Function $(if ($FunctionName) { $FunctionName } else { '*' }) -Variable *
