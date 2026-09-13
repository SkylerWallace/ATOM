@{
 SchemaVersion=1
 Actions=@{
  'windows.system-information'=@{Name='Windows system information';Description='Collect Windows version and memory details.';Source='Built-in command';Kind='SystemInformation';WorksInPE=$false;RequiresAdmin=$false;Parameters=@{}}
  'trifecta.verify-system-files'=@{Name='Verify Windows system files';Description='Verify system files with Trifecta without repairs.';Source='Trifecta';Kind='Plugin';PluginFile='Trifecta.ps1';WorksInPE=$false;RequiresAdmin=$true;Parameters=@{Action='VerifySystemFiles';NonInteractive=$true}}
 }
}
