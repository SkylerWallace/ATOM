﻿$tooltip = "Set many services to manual to improve performance`nThese services will startup when required by the system"

Write-Host "Setting Manual Services"
 
$services = @(
	@("AJRouter", "Disabled"),
	@("ALG", "Manual"),
	@("AppIDSvc", "Manual"),
	@("AppMgmt", "Manual"),
	@("AppReadiness", "Manual"),
	@("AppVClient", "Disabled"),
	@("AppXSvc", "Manual"),
	@("Appinfo", "Manual"),
	@("AssignedAccessManagerSvc", "Disabled"),
	@("autotimesvc", "Manual"),
	@("AxInstSV", "Manual"),
	@("BcastDVRUserService_*", "Manual"),
	@("BDESVC", "Manual"),
	@("BluetoothUserService_*", "Manual"),
	@("Browser", "Manual"),
	@("BTAGService", "Manual"),
	@("bthserv", "Manual"),
	@("camsvc", "Manual"),
	@("CaptureService_*", "Manual"),
#	@("cbdhsvc_*", "Manual"), # Needs more testing to determine if safe
	@("CDPSvc", "Manual"),
	@("COMSysApp", "Manual"),
	@("CertPropSvc", "Manual"),
	@("ClipSVC", "Manual"),
	@("cloudidsvc", "Manual"),
	@("ConsentUxUserSvc_*", "Manual"),
	@("CredentialEnrollmentManagerUserSvc_*", "Manual"),
	@("CscService", "Manual"),
	@("DcpSvc", "Manual"),
	@("dcsvc", "Manual"),
	@("defragsvc", "Manual"),
	@("DeviceAssociationBrokerSvc_*", "Manual"),
	@("DeviceAssociationService", "Manual"),
	@("DeviceInstall", "Manual"),
	@("DevicesFlowUserSvc_*", "Manual"),
	@("DevicePickerUserSvc_*", "Manual"),
	@("DevQueryBroker", "Manual"),
	@("diagnosticshub.standardcollector.service", "Manual"),
	@("diagsvc", "Manual"),
	@("DiagTrack", "Disabled"),
	@("DialogBlockingService", "Disabled"),
	@("DisplayEnhancementService", "Manual"),
	@("DmEnrollmentSvc", "Manual"),
	@("dmwappushservice", "Manual"),
	@("dot3svc", "Manual"),
	@("DsmSvc", "Manual"),
	@("DsSvc", "Manual"),
	@("EapHost", "Manual"),
	@("edgeupdate", "Manual"),
	@("edgeupdatem", "Manual"),
	@("EFS", "Manual"),
	@("embeddedmode", "Manual"),
	@("EntAppSvc", "Manual"),
	@("Fax", "Manual"),
	@("fdPHost", "Manual"),
	@("FDResPub", "Manual"),
	@("fhsvc", "Manual"),
	@("FrameServer", "Manual"),
	@("FrameServerMonitor", "Manual"),
	@("gupdate", "Manual"),
	@("gupdatem", "Manual"),
	@("GraphicsPerfSvc", "Manual"),
	@("hidserv", "Manual"),
	@("HomeGroupListener", "Manual"),
	@("HomeGroupProvider", "Manual"),
	@("HvHost", "Manual"),
	@("icssvc", "Manual"),
	@("IEEtwCollectorService", "Manual"),
	@("IKEEXT", "Manual"),
	@("InstallService", "Manual"),
	@("InventorySvc", "Manual"),
	@("IpxlatCfgSvc", "Manual"),
	@("KtmRm", "Manual"),
	@("lfsvc", "Manual"),
	@("LicenseManager", "Manual"),
	@("lltdsvc", "Manual"),
	@("lmhosts", "Manual"),
	@("LxpSvc", "Manual"),
	@("McpManagementService", "Manual"),
	@("MessagingService_*", "Manual"),
	@("MicrosoftEdgeElevationService", "Manual"),
	@("MixedRealityOpenXRSvc", "Manual"),
	@("MSDTC", "Manual"),
	@("MsKeyboardFilter", "Manual"),
	@("MSiSCSI", "Manual"),
	@("msiserver", "Manual"),
	@("NaturalAuthentication", "Manual"),
	@("NcaSvc", "Manual"),
	@("NcbService", "Manual"),
	@("NcdAutoSetup", "Manual"),
	@("netprofm", "Manual"),
	@("Netman", "Manual"),
	@("NetSetupSvc", "Manual"),
	@("NetTcpPortSharing", "Disabled"),
	@("NgcCtnrSvc", "Manual"),
	@("NgcSvc", "Manual"),
	@("NlaSvc", "Manual"),
	@("NPSMSvc_*", "Manual"),
	@("p2pimsvc", "Manual"),
	@("p2psvc", "Manual"),
	@("P9RdrService_*", "Manual"),
	@("PcaSvc", "Manual"),
	@("PeerDistSvc", "Manual"),
	@("PenService_*", "Manual"),
	@("perceptionsimulation", "Manual"),
	@("PerfHost", "Manual"),
	@("PhoneSvc", "Manual"),
	@("PimIndexMaintenanceSvc_*", "Manual"),
	@("pla", "Manual"),
	@("PlugPlay", "Manual"),
	@("PNRPAutoReg", "Manual"),
	@("PNRPsvc", "Manual"),
	@("PolicyAgent", "Manual"),
	@("PrintNotify", "Manual"),
	@("PrintWorkflowUserSvc_*", "Manual"),
	@("PushToInstall", "Manual"),
	@("QWAVE", "Manual"),
	@("RasAuto", "Manual"),
	@("RasMan", "Manual"),
	@("RemoteAccess", "Disabled"),
	@("RemoteRegistry", "Disabled"),
	@("RetailDemo", "Manual"),
	@("RmSvc", "Manual"),
	@("RpcLocator", "Manual"),
	@("SCardSvr", "Manual"),
	@("ScDeviceEnum", "Manual"),
	@("SCPolicySvc", "Manual"),
	@("SDRSVC", "Manual"),
	@("seclogon", "Manual"),
	@("SecurityHealthService", "Manual"),
	@("SEMgrSvc", "Manual"),
	@("Sense", "Manual"),
	@("SensorDataService", "Manual"),
	@("SensorService", "Manual"),
	@("SensrSvc", "Manual"),
	@("SessionEnv", "Manual"),
	@("SharedAccess", "Manual"),
	@("SharedRealitySvc", "Manual"),
	@("shpamsvc", "Disabled"),
	@("smphost", "Manual"),
	@("SmsRouter", "Manual"),
	@("SNMPTRAP", "Manual"),
	@("SNMPTrap", "Manual"),
	@("spectrum", "Manual"),
	@("SSDPSRV", "Manual"),
	@("ssh-agent", "Disabled"),
	@("SstpSvc", "Manual"),
#	@("StateRepository", "Manual"), # Needs more testing to determine if safe
	@("stiSvc", "Manual"),
	@("StorSvc", "Manual"),
	@("svsvc", "Manual"),
	@("swprv", "Manual"),
	@("TabletInputService", "Manual"),
	@("TapiSrv", "Manual"),
#	@("TextInputManagementService", "Manual"), # Needs more testing to determine if safe
	@("TieringEngineService", "Manual"),
	@("TimeBroker", "Manual"),
	@("TimeBrokerSvc", "Manual"),
	@("TokenBroker", "Manual"),
	@("TroubleshootingSvc", "Manual"),
	#@("TrkWks", "Manual"), # Needs more testing to determine if safe
	@("TrustedInstaller", "Manual"),
	@("tzautoupdate", "Disabled"),
	@("UdkUserSvc_*", "Manual"),
	@("UevAgentService", "Disabled"),
	@("uhssvc", "Disabled"),
	@("UI0Detect", "Manual"),
	@("UmRdpService", "Manual"),
	@("UnistoreSvc_*", "Manual"),
	@("upnphost", "Manual"),
	@("UserDataSvc_*", "Manual"),
	@("UsoSvc", "Manual"),
	@("VacSvc", "Manual"),
	@("vds", "Manual"),
	@("vm3dservice", "Manual"),
	@("vmicguestinterface", "Manual"),
	@("vmicheartbeat", "Manual"),
	@("vmickvpexchange", "Manual"),
	@("vmicrdv", "Manual"),
	@("vmicshutdown", "Manual"),
	@("vmictimesync", "Manual"),
	@("vmicvmsession", "Manual"),
	@("vmicvss", "Manual"),
	@("vmvss", "Manual"),
	@("VSS", "Manual"),
	@("W32Time", "Manual"),
	@("WaaSMedicSvc", "Manual"),
	@("WalletService", "Manual"),
	@("WarpJITSvc", "Manual"),
	@("WbioSrvc", "Manual"),
	@("wbengine", "Manual"),
	@("wcncsvc", "Manual"),
	@("WcsPlugInService", "Manual"),
	@("WdiServiceHost", "Manual"),
	@("WdiSystemHost", "Manual"),
	@("WdNisSvc", "Manual"),
	@("WebClient", "Manual"),
	@("webthreatdefsvc", "Manual"),
	@("Wecsvc", "Manual"),
	@("WEPHOSTSVC", "Manual"),
	@("wercplsupport", "Manual"),
	@("WerSvc", "Manual"),
	@("WFDSConMgrSvc", "Manual"),
	@("WiaRpc", "Manual"),
	@("WinHttpAutoProxySvc", "Manual"),
	@("WinRM", "Manual"),
	@("wisvc", "Manual"),
	@("wlidsvc", "Manual"),
	@("wlpasvc", "Manual"),
	@("WManSvc", "Manual"),
	@("wmiApSrv", "Manual"),
	@("WMPNetworkSvc", "Manual"),
	@("workfolderssvc", "Manual"),
	@("WpcMonSvc", "Manual"),
	@("WPDBusEnum", "Manual"),
	@("WpnService", "Manual"),
	@("WSService", "Manual"),
	@("wuauserv", "Manual"),
	@("wudfsvc", "Manual"),
	@("WwanSvc", "Manual"),
	@("XblAuthManager", "Manual"),
	@("XblGameSave", "Manual"),
	@("XboxGipSvc", "Manual"),
	@("XboxNetApiSvc", "Manual")
	
# HP Services	# Need to test on HP devices to determine if setting to manual interferes with HP apps
#	@("HPAppHelperCap", "Manual"),
#	@("HPDiagsCap", "Manual"),
#	@("HPNetworkCap", "Manual"),
#	@("hp-one-agent-service", "Manual"),
#	@("HPSysInfoCap", "Manual"),
#	@("HpTouchpointAnalyticsService", "Manual"),
)

# Load all services w/ Get-Service (quicker than individual calls)
$allServices = Get-Service -ErrorAction SilentlyContinue

foreach ($service in $services) {
	$serviceName = $service[0]
	$serviceValue = $service[1]
	
	# Search for specific service
	$serviceDetected = $allServices | Where-Object { $_.Name -eq $serviceName }
	
	if ($serviceDetected -and $serviceDetected.StartType -ne $serviceValue) {
		Set-Service $serviceName -StartupType $serviceValue -ErrorAction SilentlyContinue
		Write-Host "- $serviceName > $serviceValue"
	} else {
		# Commenting out for brevity
		# Write-Host "- $serviceName > Unchanged"
	}
}

Write-Host ""