Write-Host "Setting Manual Services"

$services = [ordered]@{
    # Commented entries preserve Windows/vendor defaults or require feature-specific review.
    AJRouter = @{
        FriendlyName = 'AllJoyn Router Service'
        StartupType = 'Disabled'
    }
    ALG = @{
        FriendlyName = 'Application Layer Gateway Service'
        StartupType = 'Manual'
    }
    AppIDSvc = @{
        FriendlyName = 'Application Identity'
        StartupType = 'Manual'
    }
    AppMgmt = @{
        FriendlyName = 'Application Management'
        StartupType = 'Manual'
    }
    AppReadiness = @{
        FriendlyName = 'App Readiness'
        StartupType = 'Manual'
    }
    AppVClient = @{
        FriendlyName = 'Microsoft App-V Client'
        StartupType = 'Disabled'
    }
    # AppXSvc = @{
    #     FriendlyName = 'AppX Deployment Service (AppXSVC)'
    #     StartupType = 'Manual'
    # }
    Appinfo = @{
        FriendlyName = 'Application Information'
        StartupType = 'Manual'
    }
    AssignedAccessManagerSvc = @{
        FriendlyName = 'AssignedAccessManager Service'
        StartupType = 'Disabled'
    }
    autotimesvc = @{
        FriendlyName = 'Cellular Time'
        StartupType = 'Manual'
    }
    AxInstSV = @{
        FriendlyName = 'ActiveX Installer (AxInstSV)'
        StartupType = 'Manual'
    }
    'BcastDVRUserService_*' = @{
        FriendlyName = 'GameDVR and Broadcast User Service'
        StartupType = 'Manual'
    }
    BDESVC = @{
        FriendlyName = 'BitLocker Drive Encryption Service'
        StartupType = 'Manual'
    }
    'BluetoothUserService_*' = @{
        FriendlyName = 'Bluetooth User Support Service'
        StartupType = 'Manual'
    }
    Browser = @{
        FriendlyName = 'Computer Browser'
        StartupType = 'Manual'
    }
    BTAGService = @{
        FriendlyName = 'Bluetooth Audio Gateway Service'
        StartupType = 'Manual'
    }
    bthserv = @{
        FriendlyName = 'Bluetooth Support Service'
        StartupType = 'Manual'
    }
    # camsvc = @{
    #     FriendlyName = 'Capability Access Manager Service'
    #     StartupType = 'Manual'
    # }
    'CaptureService_*' = @{
        FriendlyName = 'CaptureService'
        StartupType = 'Manual'
    }
    # 'cbdhsvc_*' = @{ # Needs more testing to determine if safe
    #     FriendlyName = 'Clipboard User Service'
    #     StartupType = 'Manual'
    # }
    # CDPSvc = @{
    #     FriendlyName = 'Connected Devices Platform Service'
    #     StartupType = 'Manual'
    # }
    COMSysApp = @{
        FriendlyName = 'COM+ System Application'
        StartupType = 'Manual'
    }
    CertPropSvc = @{
        FriendlyName = 'Certificate Propagation'
        StartupType = 'Manual'
    }
    ClipSVC = @{
        FriendlyName = 'Client License Service (ClipSVC)'
        StartupType = 'Manual'
    }
    cloudidsvc = @{
        FriendlyName = 'Microsoft Cloud Identity Service'
        StartupType = 'Manual'
    }
    'ConsentUxUserSvc_*' = @{
        FriendlyName = 'ConsentUX User Service'
        StartupType = 'Manual'
    }
    'CredentialEnrollmentManagerUserSvc_*' = @{
        FriendlyName = 'CredentialEnrollmentManagerUserSvc'
        StartupType = 'Manual'
    }
    CscService = @{
        FriendlyName = 'Offline Files'
        StartupType = 'Manual'
    }
    DcpSvc = @{
        FriendlyName = 'Data Collection and Publishing Service'
        StartupType = 'Manual'
    }
    dcsvc = @{
        FriendlyName = 'Declared Configuration(DC) service'
        StartupType = 'Manual'
    }
    defragsvc = @{
        FriendlyName = 'Optimize drives'
        StartupType = 'Manual'
    }
    'DeviceAssociationBrokerSvc_*' = @{
        FriendlyName = 'DeviceAssociationBroker'
        StartupType = 'Manual'
    }
    DeviceAssociationService = @{
        FriendlyName = 'Device Association Service'
        StartupType = 'Manual'
    }
    DeviceInstall = @{
        FriendlyName = 'Device Install Service'
        StartupType = 'Manual'
    }
    'DevicesFlowUserSvc_*' = @{
        FriendlyName = 'DevicesFlow'
        StartupType = 'Manual'
    }
    'DevicePickerUserSvc_*' = @{
        FriendlyName = 'DevicePicker'
        StartupType = 'Manual'
    }
    DevQueryBroker = @{
        FriendlyName = 'DevQuery Background Discovery Broker'
        StartupType = 'Manual'
    }
    'diagnosticshub.standardcollector.service' = @{
        FriendlyName = 'Microsoft Diagnostics Hub Standard Collector Service'
        StartupType = 'Manual'
    }
    diagsvc = @{
        FriendlyName = 'Diagnostic Execution Service'
        StartupType = 'Manual'
    }
    DiagTrack = @{
        FriendlyName = 'Connected User Experiences and Telemetry'
        StartupType = 'Disabled'
    }
    DialogBlockingService = @{
        FriendlyName = 'DialogBlockingService'
        StartupType = 'Disabled'
    }
    DisplayEnhancementService = @{
        FriendlyName = 'Display Enhancement Service'
        StartupType = 'Manual'
    }
    DmEnrollmentSvc = @{
        FriendlyName = 'Device Management Enrollment Service'
        StartupType = 'Manual'
    }
    # dmwappushservice = @{
    #     FriendlyName = 'Device Management Wireless Application Protocol (WAP) Push message Routing Service'
    #     StartupType = 'Manual'
    # }
    dot3svc = @{
        FriendlyName = 'Wired AutoConfig'
        StartupType = 'Manual'
    }
    DsmSvc = @{
        FriendlyName = 'Device Setup Manager'
        StartupType = 'Manual'
    }
    DsSvc = @{
        FriendlyName = 'Data Sharing Service'
        StartupType = 'Manual'
    }
    EapHost = @{
        FriendlyName = 'Extensible Authentication Protocol'
        StartupType = 'Manual'
    }
    # edgeupdate = @{
    #     FriendlyName = 'Microsoft Edge Update Service (edgeupdate)'
    #     StartupType = 'Manual'
    # }
    edgeupdatem = @{
        FriendlyName = 'Microsoft Edge Update Service (edgeupdatem)'
        StartupType = 'Manual'
    }
    EFS = @{
        FriendlyName = 'Encrypting File System (EFS)'
        StartupType = 'Manual'
    }
    embeddedmode = @{
        FriendlyName = 'Embedded Mode'
        StartupType = 'Manual'
    }
    EntAppSvc = @{
        FriendlyName = 'Enterprise App Management Service'
        StartupType = 'Manual'
    }
    Fax = @{
        FriendlyName = 'Fax'
        StartupType = 'Manual'
    }
    fdPHost = @{
        FriendlyName = 'Function Discovery Provider Host'
        StartupType = 'Manual'
    }
    FDResPub = @{
        FriendlyName = 'Function Discovery Resource Publication'
        StartupType = 'Manual'
    }
    fhsvc = @{
        FriendlyName = 'File History Service'
        StartupType = 'Manual'
    }
    FrameServer = @{
        FriendlyName = 'Windows Camera Frame Server'
        StartupType = 'Manual'
    }
    FrameServerMonitor = @{
        FriendlyName = 'Windows Camera Frame Server Monitor'
        StartupType = 'Manual'
    }
    # gupdate = @{
    #     FriendlyName = 'Google Update Service (gupdate)'
    #     StartupType = 'Manual'
    # }
    # gupdatem = @{
    #     FriendlyName = 'Google Update Service (gupdatem)'
    #     StartupType = 'Manual'
    # }
    GraphicsPerfSvc = @{
        FriendlyName = 'GraphicsPerfSvc'
        StartupType = 'Manual'
    }
    hidserv = @{
        FriendlyName = 'Human Interface Device Service'
        StartupType = 'Manual'
    }
    HomeGroupListener = @{
        FriendlyName = 'HomeGroup Listener'
        StartupType = 'Manual'
    }
    HomeGroupProvider = @{
        FriendlyName = 'HomeGroup Provider'
        StartupType = 'Manual'
    }
    HvHost = @{
        FriendlyName = 'HV Host Service'
        StartupType = 'Manual'
    }
    icssvc = @{
        FriendlyName = 'Windows Mobile Hotspot Service'
        StartupType = 'Manual'
    }
    IEEtwCollectorService = @{
        FriendlyName = 'Internet Explorer ETW Collector Service'
        StartupType = 'Manual'
    }
    IKEEXT = @{
        FriendlyName = 'IKE and AuthIP IPsec Keying Modules'
        StartupType = 'Manual'
    }
    InstallService = @{
        FriendlyName = 'Microsoft Store Install Service'
        StartupType = 'Manual'
    }
    # InventorySvc = @{
    #     FriendlyName = 'Inventory and Compatibility Appraisal service'
    #     StartupType = 'Manual'
    # }
    IpxlatCfgSvc = @{
        FriendlyName = 'IP Translation Configuration Service'
        StartupType = 'Manual'
    }
    KtmRm = @{
        FriendlyName = 'KtmRm for Distributed Transaction Coordinator'
        StartupType = 'Manual'
    }
    lfsvc = @{
        FriendlyName = 'Geolocation Service'
        StartupType = 'Manual'
    }
    LicenseManager = @{
        FriendlyName = 'Windows License Manager Service'
        StartupType = 'Manual'
    }
    lltdsvc = @{
        FriendlyName = 'Link-Layer Topology Discovery Mapper'
        StartupType = 'Manual'
    }
    lmhosts = @{
        FriendlyName = 'TCP/IP NetBIOS Helper'
        StartupType = 'Manual'
    }
    LxpSvc = @{
        FriendlyName = 'Language Experience Service'
        StartupType = 'Manual'
    }
    MapsBroker = @{
        FriendlyName = 'Downloaded Maps Manager'
        StartupType = 'Manual'
    }
    McpManagementService = @{
        FriendlyName = 'McpManagementService'
        StartupType = 'Manual'
    }
    'MessagingService_*' = @{
        FriendlyName = 'MessagingService'
        StartupType = 'Manual'
    }
    MicrosoftEdgeElevationService = @{
        FriendlyName = 'Microsoft Edge Elevation Service (MicrosoftEdgeElevationService)'
        StartupType = 'Manual'
    }
    MixedRealityOpenXRSvc = @{
        FriendlyName = 'Windows Mixed Reality OpenXR Service'
        StartupType = 'Manual'
    }
    MSDTC = @{
        FriendlyName = 'Distributed Transaction Coordinator'
        StartupType = 'Manual'
    }
    # MsKeyboardFilter = @{
    #     FriendlyName = 'Microsoft Keyboard Filter'
    #     StartupType = 'Manual'
    # }
    MSiSCSI = @{
        FriendlyName = 'Microsoft iSCSI Initiator Service'
        StartupType = 'Manual'
    }
    msiserver = @{
        FriendlyName = 'Windows Installer'
        StartupType = 'Manual'
    }
    NaturalAuthentication = @{
        FriendlyName = 'Natural Authentication'
        StartupType = 'Manual'
    }
    NcaSvc = @{
        FriendlyName = 'Network Connectivity Assistant'
        StartupType = 'Manual'
    }
    NcbService = @{
        FriendlyName = 'Network Connection Broker'
        StartupType = 'Manual'
    }
    NcdAutoSetup = @{
        FriendlyName = 'Network Connected Devices Auto-Setup'
        StartupType = 'Manual'
    }
    netprofm = @{
        FriendlyName = 'Network List Service'
        StartupType = 'Manual'
    }
    Netman = @{
        FriendlyName = 'Network Connections'
        StartupType = 'Manual'
    }
    # NetSetupSvc = @{
    #     FriendlyName = 'Network Setup Service'
    #     StartupType = 'Manual'
    # }
    NetTcpPortSharing = @{
        FriendlyName = 'Net.Tcp Port Sharing Service'
        StartupType = 'Disabled'
    }
    NgcCtnrSvc = @{
        FriendlyName = 'Microsoft Passport Container'
        StartupType = 'Manual'
    }
    NgcSvc = @{
        FriendlyName = 'Microsoft Passport'
        StartupType = 'Manual'
    }
    # NlaSvc = @{
    #     FriendlyName = 'Network Location Awareness'
    #     StartupType = 'Manual'
    # }
    'NPSMSvc_*' = @{
        FriendlyName = 'Now Playing Session Manager Service'
        StartupType = 'Manual'
    }
    p2pimsvc = @{
        FriendlyName = 'Peer Networking Identity Manager'
        StartupType = 'Manual'
    }
    p2psvc = @{
        FriendlyName = 'Peer Networking Grouping'
        StartupType = 'Manual'
    }
    'P9RdrService_*' = @{
        FriendlyName = 'P9RdrService'
        StartupType = 'Manual'
    }
    # PcaSvc = @{
    #     FriendlyName = 'Program Compatibility Assistant Service'
    #     StartupType = 'Manual'
    # }
    PeerDistSvc = @{
        FriendlyName = 'BranchCache'
        StartupType = 'Manual'
    }
    'PenService_*' = @{
        FriendlyName = 'PenService'
        StartupType = 'Manual'
    }
    perceptionsimulation = @{
        FriendlyName = 'Windows Perception Simulation Service'
        StartupType = 'Manual'
    }
    PerfHost = @{
        FriendlyName = 'Performance Counter DLL Host'
        StartupType = 'Manual'
    }
    PhoneSvc = @{
        FriendlyName = 'Phone Service'
        StartupType = 'Manual'
    }
    'PimIndexMaintenanceSvc_*' = @{
        FriendlyName = 'Contact Data'
        StartupType = 'Manual'
    }
    pla = @{
        FriendlyName = 'Performance Logs & Alerts'
        StartupType = 'Manual'
    }
    PlugPlay = @{
        FriendlyName = 'Plug and Play'
        StartupType = 'Manual'
    }
    PNRPAutoReg = @{
        FriendlyName = 'PNRP Machine Name Publication Service'
        StartupType = 'Manual'
    }
    PNRPsvc = @{
        FriendlyName = 'Peer Name Resolution Protocol'
        StartupType = 'Manual'
    }
    PolicyAgent = @{
        FriendlyName = 'IPsec Policy Agent'
        StartupType = 'Manual'
    }
    PrintNotify = @{
        FriendlyName = 'Printer Extensions and Notifications'
        StartupType = 'Manual'
    }
    'PrintWorkflowUserSvc_*' = @{
        FriendlyName = 'PrintWorkflow'
        StartupType = 'Manual'
    }
    PushToInstall = @{
        FriendlyName = 'Windows PushToInstall Service'
        StartupType = 'Manual'
    }
    QWAVE = @{
        FriendlyName = 'Quality Windows Audio Video Experience'
        StartupType = 'Manual'
    }
    RasAuto = @{
        FriendlyName = 'Remote Access Auto Connection Manager'
        StartupType = 'Manual'
    }
    RasMan = @{
        FriendlyName = 'Remote Access Connection Manager'
        StartupType = 'Manual'
    }
    RemoteAccess = @{
        FriendlyName = 'Routing and Remote Access'
        StartupType = 'Disabled'
    }
    RemoteRegistry = @{
        FriendlyName = 'Remote Registry'
        StartupType = 'Disabled'
    }
    RetailDemo = @{
        FriendlyName = 'Retail Demo Service'
        StartupType = 'Manual'
    }
    RmSvc = @{
        FriendlyName = 'Radio Management Service'
        StartupType = 'Manual'
    }
    RpcLocator = @{
        FriendlyName = 'Remote Procedure Call (RPC) Locator'
        StartupType = 'Manual'
    }
    # SCardSvr = @{
    #     FriendlyName = 'Smart Card'
    #     StartupType = 'Manual'
    # }
    ScDeviceEnum = @{
        FriendlyName = 'Smart Card Device Enumeration Service'
        StartupType = 'Manual'
    }
    SCPolicySvc = @{
        FriendlyName = 'Smart Card Removal Policy'
        StartupType = 'Manual'
    }
    SDRSVC = @{
        FriendlyName = 'Windows Backup'
        StartupType = 'Manual'
    }
    seclogon = @{
        FriendlyName = 'Secondary Logon'
        StartupType = 'Manual'
    }
    # SecurityHealthService = @{
    #     FriendlyName = 'Windows Security Service'
    #     StartupType = 'Manual'
    # }
    SEMgrSvc = @{
        FriendlyName = 'Payments and NFC/SE Manager'
        StartupType = 'Manual'
    }
    Sense = @{
        FriendlyName = 'Windows Defender Advanced Threat Protection Service'
        StartupType = 'Manual'
    }
    SensorDataService = @{
        FriendlyName = 'Sensor Data Service'
        StartupType = 'Manual'
    }
    SensorService = @{
        FriendlyName = 'Sensor Service'
        StartupType = 'Manual'
    }
    SensrSvc = @{
        FriendlyName = 'Sensor Monitoring Service'
        StartupType = 'Manual'
    }
    SessionEnv = @{
        FriendlyName = 'Remote Desktop Configuration'
        StartupType = 'Manual'
    }
    SharedAccess = @{
        FriendlyName = 'Internet Connection Sharing (ICS)'
        StartupType = 'Manual'
    }
    SharedRealitySvc = @{
        FriendlyName = 'Spatial Data Service'
        StartupType = 'Manual'
    }
    shpamsvc = @{
        FriendlyName = 'Shared PC Account Manager'
        StartupType = 'Disabled'
    }
    smphost = @{
        FriendlyName = 'Microsoft Storage Spaces SMP'
        StartupType = 'Manual'
    }
    # SmsRouter = @{
    #     FriendlyName = 'Microsoft Windows SMS Router Service.'
    #     StartupType = 'Manual'
    # }
    SNMPTRAP = @{
        FriendlyName = 'SNMP Trap'
        StartupType = 'Manual'
    }
    spectrum = @{
        FriendlyName = 'Windows Perception Service'
        StartupType = 'Manual'
    }
    SSDPSRV = @{
        FriendlyName = 'SSDP Discovery'
        StartupType = 'Manual'
    }
    'ssh-agent' = @{
        FriendlyName = 'OpenSSH Authentication Agent'
        StartupType = 'Disabled'
    }
    SstpSvc = @{
        FriendlyName = 'Secure Socket Tunneling Protocol Service'
        StartupType = 'Manual'
    }
    # StateRepository = @{ # Needs more testing to determine if safe
    #     FriendlyName = 'State Repository Service'
    #     StartupType = 'Manual'
    # }
    stiSvc = @{
        FriendlyName = 'Windows Image Acquisition (WIA)'
        StartupType = 'Manual'
    }
    StorSvc = @{
        FriendlyName = 'Storage Service'
        StartupType = 'Manual'
    }
    svsvc = @{
        FriendlyName = 'Spot Verifier'
        StartupType = 'Manual'
    }
    swprv = @{
        FriendlyName = 'Microsoft Software Shadow Copy Provider'
        StartupType = 'Manual'
    }
    TabletInputService = @{
        FriendlyName = 'Touch Keyboard and Handwriting Panel Service'
        StartupType = 'Manual'
    }
    TapiSrv = @{
        FriendlyName = 'Telephony'
        StartupType = 'Manual'
    }
    # TextInputManagementService = @{ # Needs more testing to determine if safe
    #     FriendlyName = 'Text Input Management Service'
    #     StartupType = 'Manual'
    # }
    TieringEngineService = @{
        FriendlyName = 'Storage Tiers Management'
        StartupType = 'Manual'
    }
    TimeBroker = @{
        FriendlyName = 'Time Broker'
        StartupType = 'Manual'
    }
    TimeBrokerSvc = @{
        FriendlyName = 'Time Broker'
        StartupType = 'Manual'
    }
    TokenBroker = @{
        FriendlyName = 'Web Account Manager'
        StartupType = 'Manual'
    }
    TroubleshootingSvc = @{
        FriendlyName = 'Recommended Troubleshooting Service'
        StartupType = 'Manual'
    }
    # TrkWks = @{ # Needs more testing to determine if safe
    #     FriendlyName = 'Distributed Link Tracking Client'
    #     StartupType = 'Manual'
    # }
    # TrustedInstaller = @{
    #     FriendlyName = 'Windows Modules Installer'
    #     StartupType = 'Manual'
    # }
    tzautoupdate = @{
        FriendlyName = 'Auto Time Zone Updater'
        StartupType = 'Disabled'
    }
    'UdkUserSvc_*' = @{
        FriendlyName = 'Udk User Service'
        StartupType = 'Manual'
    }
    UevAgentService = @{
        FriendlyName = 'User Experience Virtualization Service'
        StartupType = 'Disabled'
    }
    uhssvc = @{
        FriendlyName = 'Microsoft Update Health Service'
        StartupType = 'Disabled'
    }
    UI0Detect = @{
        FriendlyName = 'Interactive Services Detection'
        StartupType = 'Manual'
    }
    UmRdpService = @{
        FriendlyName = 'Remote Desktop Services UserMode Port Redirector'
        StartupType = 'Manual'
    }
    'UnistoreSvc_*' = @{
        FriendlyName = 'User Data Storage'
        StartupType = 'Manual'
    }
    upnphost = @{
        FriendlyName = 'UPnP Device Host'
        StartupType = 'Manual'
    }
    'UserDataSvc_*' = @{
        FriendlyName = 'User Data Access'
        StartupType = 'Manual'
    }
    # UsoSvc = @{
    #     FriendlyName = 'Update Orchestrator Service'
    #     StartupType = 'Manual'
    # }
    VacSvc = @{
        FriendlyName = 'Volumetric Audio Compositor Service'
        StartupType = 'Manual'
    }
    vds = @{
        FriendlyName = 'Virtual Disk'
        StartupType = 'Manual'
    }
    # vm3dservice = @{
    #     FriendlyName = 'VMware SVGA Helper Service'
    #     StartupType = 'Manual'
    # }
    vmicguestinterface = @{
        FriendlyName = 'Hyper-V Guest Service Interface'
        StartupType = 'Manual'
    }
    vmicheartbeat = @{
        FriendlyName = 'Hyper-V Heartbeat Service'
        StartupType = 'Manual'
    }
    vmickvpexchange = @{
        FriendlyName = 'Hyper-V Data Exchange Service'
        StartupType = 'Manual'
    }
    vmicrdv = @{
        FriendlyName = 'Hyper-V Remote Desktop Virtualization Service'
        StartupType = 'Manual'
    }
    vmicshutdown = @{
        FriendlyName = 'Hyper-V Guest Shutdown Service'
        StartupType = 'Manual'
    }
    vmictimesync = @{
        FriendlyName = 'Hyper-V Time Synchronization Service'
        StartupType = 'Manual'
    }
    vmicvmsession = @{
        FriendlyName = 'Hyper-V PowerShell Direct Service'
        StartupType = 'Manual'
    }
    vmicvss = @{
        FriendlyName = 'Hyper-V Volume Shadow Copy Requestor'
        StartupType = 'Manual'
    }
    vmvss = @{
        FriendlyName = 'VMware Snapshot Provider'
        StartupType = 'Manual'
    }
    VSS = @{
        FriendlyName = 'Volume Shadow Copy'
        StartupType = 'Manual'
    }
    W32Time = @{
        FriendlyName = 'Windows Time'
        StartupType = 'Manual'
    }
    WaaSMedicSvc = @{
        FriendlyName = 'Windows Update Medic Service'
        StartupType = 'Manual'
    }
    WalletService = @{
        FriendlyName = 'WalletService'
        StartupType = 'Manual'
    }
    WarpJITSvc = @{
        FriendlyName = 'Warp JIT Service'
        StartupType = 'Manual'
    }
    WbioSrvc = @{
        FriendlyName = 'Windows Biometric Service'
        StartupType = 'Manual'
    }
    wbengine = @{
        FriendlyName = 'Block Level Backup Engine Service'
        StartupType = 'Manual'
    }
    wcncsvc = @{
        FriendlyName = 'Windows Connect Now - Config Registrar'
        StartupType = 'Manual'
    }
    WcsPlugInService = @{
        FriendlyName = 'Windows Color System'
        StartupType = 'Manual'
    }
    WdiServiceHost = @{
        FriendlyName = 'Diagnostic Service Host'
        StartupType = 'Manual'
    }
    WdiSystemHost = @{
        FriendlyName = 'Diagnostic System Host'
        StartupType = 'Manual'
    }
    WdNisSvc = @{
        FriendlyName = 'Microsoft Defender Antivirus Network Inspection Service'
        StartupType = 'Manual'
    }
    WebClient = @{
        FriendlyName = 'WebClient'
        StartupType = 'Manual'
    }
    webthreatdefsvc = @{
        FriendlyName = 'Web Threat Defense Service'
        StartupType = 'Manual'
    }
    Wecsvc = @{
        FriendlyName = 'Windows Event Collector'
        StartupType = 'Manual'
    }
    WEPHOSTSVC = @{
        FriendlyName = 'Windows Encryption Provider Host Service'
        StartupType = 'Manual'
    }
    wercplsupport = @{
        FriendlyName = 'Problem Reports Control Panel Support'
        StartupType = 'Manual'
    }
    WerSvc = @{
        FriendlyName = 'Windows Error Reporting Service'
        StartupType = 'Manual'
    }
    WFDSConMgrSvc = @{
        FriendlyName = 'Wi-Fi Direct Services Connection Manager Service'
        StartupType = 'Manual'
    }
    WiaRpc = @{
        FriendlyName = 'Still Image Acquisition Events'
        StartupType = 'Manual'
    }
    WinHttpAutoProxySvc = @{
        FriendlyName = 'WinHTTP Web Proxy Auto-Discovery Service'
        StartupType = 'Manual'
    }
    WinRM = @{
        FriendlyName = 'Windows Remote Management (WS-Management)'
        StartupType = 'Manual'
    }
    wisvc = @{
        FriendlyName = 'Windows Insider Service'
        StartupType = 'Manual'
    }
    wlidsvc = @{
        FriendlyName = 'Microsoft Account Sign-in Assistant'
        StartupType = 'Manual'
    }
    wlpasvc = @{
        FriendlyName = 'Local Profile Assistant Service'
        StartupType = 'Manual'
    }
    WManSvc = @{
        FriendlyName = 'Windows Management Service'
        StartupType = 'Manual'
    }
    wmiApSrv = @{
        FriendlyName = 'WMI Performance Adapter'
        StartupType = 'Manual'
    }
    WMPNetworkSvc = @{
        FriendlyName = 'Windows Media Player Network Sharing Service'
        StartupType = 'Manual'
    }
    workfolderssvc = @{
        FriendlyName = 'Work Folders'
        StartupType = 'Manual'
    }
    WpcMonSvc = @{
        FriendlyName = 'Parental Controls'
        StartupType = 'Manual'
    }
    WPDBusEnum = @{
        FriendlyName = 'Portable Device Enumerator Service'
        StartupType = 'Manual'
    }
    # WpnService = @{
    #     FriendlyName = 'Windows Push Notifications System Service'
    #     StartupType = 'Manual'
    # }
    WSService = @{
        FriendlyName = 'Windows Store Service (WSService)'
        StartupType = 'Manual'
    }
    wuauserv = @{
        FriendlyName = 'Windows Update'
        StartupType = 'Manual'
    }
    wudfsvc = @{
        FriendlyName = 'Windows Driver Foundation - User-mode Driver Framework'
        StartupType = 'Manual'
    }
    WwanSvc = @{
        FriendlyName = 'WWAN AutoConfig'
        StartupType = 'Manual'
    }
    XblAuthManager = @{
        FriendlyName = 'Xbox Live Auth Manager'
        StartupType = 'Manual'
    }
    XblGameSave = @{
        FriendlyName = 'Xbox Live Game Save'
        StartupType = 'Manual'
    }
    XboxGipSvc = @{
        FriendlyName = 'Xbox Accessory Management Service'
        StartupType = 'Manual'
    }
    XboxNetApiSvc = @{
        FriendlyName = 'Xbox Live Networking Service'
        StartupType = 'Manual'
    }
    # HP services
    HPAppHelperCap = @{
        FriendlyName = 'HP App Helper HSA Service'
        StartupType = 'Manual'
    }
    HPDiagsCap = @{
        FriendlyName = 'HP Diagnostics HSA Service'
        StartupType = 'Manual'
    }
    HPNetworkCap = @{
        FriendlyName = 'HP Network HSA Service'
        StartupType = 'Manual'
    }
    'hp-one-agent-service' = @{
        FriendlyName = 'HP One Agent'
        StartupType = 'Manual'
    }
    HPSysInfoCap = @{
        FriendlyName = 'HP System Info HSA Service'
        StartupType = 'Manual'
    }
    HpTouchpointAnalyticsService = @{
        FriendlyName = 'HP Touchpoint Analytics Client'
        StartupType = 'Manual'
    }
}

# Load all services once instead of querying each entry.
$allServices = Get-Service -ErrorAction Stop

foreach ($serviceName in $services.Keys) {
    $service = $services[$serviceName]
    $serviceDetected = $allServices | Where-Object { $_.Name -eq $serviceName }

    if ($serviceDetected -and $serviceDetected.StartType -ne $service.StartupType) {
        Set-Service -Name $serviceName -StartupType $service.StartupType -ErrorAction Stop
        Write-Host "- $($service.FriendlyName) ($serviceName) > $($service.StartupType)"
    }
}

Write-Host ""
