function Set-AtomPluginPreference {
    param (
        [Parameter(Mandatory)]
        [String]$Name,

        [Parameter(Mandatory)]
        [ValidateSet('Category', 'Hidden', 'Favorite')]
        [String]$Property,

        [Parameter(Mandatory)]
        [Object]$Value
    )

    $userPlugin = $script:userPluginRecords | Where-Object Name -eq $Name | Select-Object -First 1
    if ($userPlugin) {
        $metadata = @{}
        foreach ($key in $userPlugin.Metadata.Keys) { $metadata[$key] = $userPlugin.Metadata[$key] }
        $metadata[$Property] = $Value
        $userPlugin.Id = Save-AtomUserPlugin -RootPath $atomPath -Id $userPlugin.Id -Metadata $metadata
        $userPlugin.IsUserOwned = $true
        $userPlugin.Metadata[$Property] = $Value
        foreach ($item in Get-AtomPluginItems | Where-Object { $_.Tag.Name -eq $Name }) {
            $item.Tag.UserPluginId = $userPlugin.Id
            $item.Tag.IsUserOwned = $true
            $item.ContextMenu = $null
        }
        return
    }
    $overridePath = Join-Path $configPath 'PluginsUser.ps1'
    Set-AtomPluginOverride -Path $overridePath -Defaults $script:programDefaults -Name $Name -Property $Property -Value $Value
}
