# Program array
$programs = @(
# General Manual Uninstallers
	"Google Toolbar for Internet Explorer",
#	"Windows PC Health Check",
# Acer OEM Manual Uninstallers
# ASUS OEM Manual Uninstallers
	"ASUS AI Recovery",
	"ASUS FancyStart",
	"ASUS Live Update",
	"ASUS Power4Gear Hybrid",
	"ASUS SmartLogon",
	"ASUS Splendid Video Enhancement Technology",
	"ASUS Virtual Camera",
	"ASUS WebStorage",
	"ASUS Welcome",
	"AsusVibe",
# Dell OEM Manual Uninstallers
	"Dell Customer Connect",
	"Dell Digital Delivery",
	"Dell Digital Delivery Services",
#   "Dell Help & Support",
	"Dell Mobile Connect Driver",
	"Dell Product Registration",
	"Dell Shop",
#	"Dell SupportAssist",
#	"Dell SupportAssist OS Recovery Plugin",
#	"Dell SupportAssist Remediation",
#	"Dell Update",
#	"Dell Update for Windows 10",
#	"Fusion Service",
	"QuickSet64",
	"SmartByte",
	"SmartByte Drivers & Services",
# HP OEM Manual Uninstallers
#	"Bonjour",
#	"Duet Display",
#	"ExpressVPN",
	"HP Documentation",
#	"HP Connection Optimizer",
	"HP Jumpstart Apps",
	"HP Jumpstart Bridge",
	"HP Jumpstart Launch",
#	"WildTangent Games",
#	"WildTangent Helper",
#	"WildTangent Shortcut Provider",
# Lenovo OEM Manual Uninstallers
#	"Lenovo Smart Appearance Components",
	"Lenovo Voice Service",
	"Lenovo Welcome",
	"Smart Note"
# MSI OEM Manual Uninstallers
# Razer OEM Manual Uninstallers
# Samsung OEM Manual Uninstallers
	"BatteryLifeExtender",
	"Easy Content Share",
	"Easy Display Manager",
	"Easy Display Manager Option",
	"Easy Migration",
	"Easy Network Manager",
	"Easy Network Manager Help",
	"EasyFileShare",
	"Fast Start",
	"Movie Color Enhancer",
	"Movie Color Enhancer Option",
	"Samsung Support Center",
	"Samsung Update Plus",
	"Samsung Update Plust Help"
)

Uninstall-Programs

$programs = @(
	@("Bonjour", "PLACEHOLDER", "PLACEHOLDER", "PLACEHOLDER"),
	@("Duet Display", "$($uninstallPaths[0])\{E1EAAFF3-A845-4290-AA18-120205493DB3}", 'msiexec.exe /x "{E1EAAFF3-A845-4290-AA18-120205493DB3}"', "$($env:appdata)\duet\duet.ini"),
	@("ExpressVPN", "$($uninstallPaths[1])\{91acec93-88d2-4afe-bbc3-e3e376c03732}", '"C:\ProgramData\Package Cache\{91acec93-88d2-4afe-bbc3-e3e376c03732}\ExpressVPN_10.9.0.20.exe"  /uninstall', "$($env:localappdata)\ExpressVPN\ExpressVPN.exe_Url_gwqkjzvdy3xpznw2dfneavuubxdnvnis"),
	@("HP Connection Optimizer", "$($uninstallPaths[1])\{6468C4A5-E47E-405F-B675-A70A70983EA6}", '"C:\Program Files (x86)\InstallShield Installation Information\{6468C4A5-E47E-405F-B675-A70A70983EA6}\setup.exe" "-runfromtemp" "-l0x0409" "-removeonly"', "DUMMYDIR")
)

Uninstall-ProgramsAlt