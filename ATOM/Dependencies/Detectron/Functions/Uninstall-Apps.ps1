function Uninstall-Apps {
    if ($selectedApps) {
        Write-Host "AppX Bloatware"
        
        foreach ($app in $selectedApps) {
            Write-Host "- Uninstalling $app"
            Get-AppxPackage -Name $apps[$app]['PackageName'] | Remove-AppxPackage
        }
        
        Write-Host ""
    }
}