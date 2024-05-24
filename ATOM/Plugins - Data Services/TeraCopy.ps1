$atomPath = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$dependenciesPath = Join-Path $atomPath "Dependencies"
. (Join-Path $dependenciesPath "Programs-Hashtable.ps1")
. (Join-Path $dependenciesPath "Start-PortableProgram.ps1")
Start-PortableProgram -ProgramKey "TeraCopy"