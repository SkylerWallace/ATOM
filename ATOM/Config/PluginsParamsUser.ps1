## Add info for custom plugins here.
## The update feature in ATOM will remove Plugins-Hashtable.ps1
## but will not remove Plugins-Hashtable (Custom).ps1 making
## this .ps1 safe from updates.

<#
- Hidden
    Boolean. Default visibility of plugin.
- Silent
    Boolean. Launch plugin in hidden window mode.
- ToolTip
    String. Displays tooltip when mouse is hovered over respective plugin.
- WorksInOs
    Boolean. Specifies if program works in online OS.
- WorksInPe
    Boolean. Specifies if program works in PE (Windows RE/Windows PE).
#>

$customPluginInfo = [ordered]@{
    
    <#
    'Example' = @{
        Hidden    = $false
        Silent    = $true
        ToolTip   = "Default tooltip"
        WorksInOs = $true
        WorksInPe = $false
    #>
    
}