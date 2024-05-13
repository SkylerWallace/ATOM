## Add info for custom plugins here.
## The update feature in ATOM will remove Plugins-Hashtable.ps1
## but will not remove Plugins-Hashtable (Custom).ps1 making
## this .ps1 safe from updates.

<#
- Hidden
	Boolean. Default visibility of plugin.
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
		ToolTip		= "Default tooltip"
		WorksInOs	= $true
		WorksInOs	= $true
	#>
	
}