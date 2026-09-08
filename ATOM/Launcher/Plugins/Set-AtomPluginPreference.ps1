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
    if ($userPlugin -and $script:programDefaults.Keys -notcontains $Name -and $script:pluginFiles.BaseName -notcontains $Name) {
        $metadata = @{}
        foreach ($key in $userPlugin.Metadata.Keys) { $metadata[$key] = $userPlugin.Metadata[$key] }
        $metadata[$Property] = $Value
        [void](Save-AtomUserPlugin -RootPath (Join-Path (Split-Path $atomPath) 'UserPlugins') -Id $userPlugin.Id -Metadata $metadata)
        $userPlugin.Metadata[$Property] = $Value
        return
    }
    $overridePath = Join-Path $configPath 'PluginsUser.ps1'
    Set-AtomPluginOverride -Path $overridePath -Defaults $script:programDefaults -Name $Name -Property $Property -Value $Value
}
