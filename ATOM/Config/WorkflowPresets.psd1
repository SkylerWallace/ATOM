@{
 SchemaVersion=1
 Presets=@(
  @{Id='windows.diagnostics';Name='Windows diagnostics';Description='Collect Windows information, then verify protected system files without repairing them.';Actions=@('windows.system-information','trifecta.verify-system-files')}
 )
}
