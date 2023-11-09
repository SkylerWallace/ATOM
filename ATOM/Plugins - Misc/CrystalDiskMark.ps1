# Launch: Hidden

$atomPath = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$dependenciesPath = Join-Path $atomPath "Dependencies"
$hashtable = Join-Path $dependenciesPath "Programs-Hashtable.ps1"
$function = Join-Path $dependenciesPath "Start-PortableProgram.ps1"

. $hashtable
. $function

Start-PortableProgram -programKey 'CrystalDiskMark'