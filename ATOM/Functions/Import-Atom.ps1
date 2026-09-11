<#
.SYNOPSIS
    Loads explicitly requested ATOM functions into the caller's scope.
.DESCRIPTION
    Dot-source this script. Dependencies are resolved from FunctionIndex.psd1,
    read once per import, and parsed together. No catalog, filesystem setup, or
    theme initialization occurs unless requested through Feature.
.EXAMPLE
    . "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function Copy-WebItem
.EXAMPLE
    . "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function Start-Program -Feature Catalog
#>
[CmdletBinding()]
param (
    [Alias('Function')][String[]]$AtomFunction = @(),
    [Alias('Group')][String[]]$AtomGroup = @(),
    [ValidateSet('Context', 'Catalog', 'Wpf')]
    [Alias('Feature')][String[]]$AtomFeature = @(),
    [Alias('Force')][Switch]$ReloadAtomFunction
)

if ($MyInvocation.InvocationName -ne '.') {
    throw 'Dot-source Import-Atom.ps1 so functions are loaded into your script scope.'
}

# Keep all loader bookkeeping inside one object; never overwrite caller loop or
# path variables while a function requests additional helpers.
$__atomIndexPath = Join-Path $PSScriptRoot 'FunctionIndex.psd1'
$__atomIndexStamp = [IO.File]::GetLastWriteTimeUtc($__atomIndexPath)
if ($ReloadAtomFunction -or !(Get-Variable __atomLibraryIndex -ErrorAction SilentlyContinue) -or $__atomLibraryIndex.Path -ne $__atomIndexPath -or $__atomLibraryIndex.Stamp -ne $__atomIndexStamp) {
    $__atomLibraryIndex = @{
        Path = $__atomIndexPath
        Stamp = $__atomIndexStamp
        Data = Import-PowerShellDataFile -LiteralPath $__atomIndexPath
    }
}
$__atomImport = @{
    Root = $PSScriptRoot
    Index = $__atomLibraryIndex.Data
    Requested = [Collections.Generic.List[String]]::new()
    Pending = [Collections.Generic.Stack[String]]::new()
    Seen = [Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
    Source = [Text.StringBuilder]::new()
    NeedsWpf = $AtomFeature -contains 'Wpf'
}
foreach ($__atomName in $AtomFunction) { $__atomImport.Requested.Add($__atomName) }
foreach ($__atomName in $AtomGroup) {
    if (!$__atomImport.Index.Groups.ContainsKey($__atomName)) { throw "Unknown ATOM function group '$__atomName'." }
    foreach ($__atomMember in $__atomImport.Index.Groups[$__atomName]) { $__atomImport.Requested.Add($__atomMember) }
}
if ($AtomFeature -contains 'Wpf') {
    foreach ($__atomMember in $__atomImport.Index.Groups.Wpf) { $__atomImport.Requested.Add($__atomMember) }
}
foreach ($__atomName in $__atomImport.Requested) { $__atomImport.Pending.Push($__atomName) }
while ($__atomImport.Pending.Count) {
    $__atomName = $__atomImport.Pending.Pop()
    if (!$__atomImport.Seen.Add($__atomName)) { continue }
    if (!$__atomImport.Index.Functions.ContainsKey($__atomName)) { throw "Unknown ATOM function '$__atomName'." }
    $__atomEntry = $__atomImport.Index.Functions[$__atomName]
    foreach ($__atomDependency in $__atomEntry.DependsOn) { $__atomImport.Pending.Push($__atomDependency) }
    if ($__atomEntry.ContainsKey('Wpf') -and $__atomEntry.Wpf) { $__atomImport.NeedsWpf = $true }
}
# Validate the complete closure before installing any definitions. Function
# definitions may refer to each other, so mutually-referential UI helpers work.
$__atomBoundary = [IO.Path]::GetFullPath([IO.Path]::GetDirectoryName($__atomImport.Root)) + [IO.Path]::DirectorySeparatorChar
foreach ($__atomName in ($__atomImport.Seen | Sort-Object)) {
    if (!$ReloadAtomFunction -and $ExecutionContext.SessionState.InvokeProvider.Item.Exists("Function:\$__atomName")) { continue }
    $__atomEntry = $__atomImport.Index.Functions[$__atomName]
    $__atomFile = [IO.Path]::GetFullPath([IO.Path]::Combine($__atomImport.Root, $__atomEntry.Path))
    if (!$__atomFile.StartsWith($__atomBoundary, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Function '$__atomName' resolves outside the ATOM library."
    }
    [void]$__atomImport.Source.AppendLine([IO.File]::ReadAllText($__atomFile))
}
if ($__atomImport.NeedsWpf) { Add-Type -AssemblyName PresentationFramework }
if ($__atomImport.Source.Length) { . ([ScriptBlock]::Create($__atomImport.Source.ToString())) }

if ($AtomFeature.Count) {
    . (Join-Path $__atomImport.Root 'Bootstrap/Initialize-AtomContext.ps1')
}
if ($AtomFeature -contains 'Catalog') { . (Join-Path $configPath 'Plugins.ps1') }
if ($AtomFeature -contains 'Wpf') { . (Join-Path $__atomImport.Root 'Bootstrap/Initialize-AtomWpf.ps1') }

Remove-Variable -Name __atomImport, __atomName, __atomMember, __atomEntry, __atomDependency, __atomFile, __atomBoundary, __atomIndexPath, __atomIndexStamp -ErrorAction SilentlyContinue
