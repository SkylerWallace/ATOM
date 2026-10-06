function Get-AtomComputerInventory {
    <# .SYNOPSIS
        Collects best-effort native hardware inventory once per workflow.
    .DESCRIPTION
        Drive usage covers readable volumes only. Unallocated space and
        inaccessible volumes are excluded from used capacity.
    #>
    param([string]$AtomRoot)
    $errors = [Collections.Generic.List[string]]::new()
    $query = {
        param([string]$Class, [string[]]$Property, [string]$Namespace = 'root/cimv2')
        try { @(Get-CimInstance -Namespace $Namespace -ClassName $Class -Property $Property -OperationTimeoutSec 2 -ErrorAction Stop) }
        catch { $errors.Add("${Class}: $($_.Exception.Message)") }
    }
    $inPE = (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT') -or (Test-Path (Join-Path $env:SystemRoot 'System32/wpeutil.exe'))
    $software = if ($inPE) { 'HKLM:\RemoteOS-HKLM-SOFTWARE' } else { 'HKLM:\SOFTWARE' }
    $systemHive = if ($inPE) { 'HKLM:\RemoteOS-HKLM-SYSTEM' } else { 'HKLM:\SYSTEM' }
    $target = if ($inPE) { (Get-ItemProperty 'HKLM:\SOFTWARE\ATOM' -Name MountedDrive -ErrorAction SilentlyContinue).MountedDrive } else { [IO.Path]::GetPathRoot($env:SystemRoot).TrimEnd('\') }
    $windows = $null
    try {
        $current = Get-ItemProperty "$software\Microsoft\Windows NT\CurrentVersion" -ErrorAction Stop
        $controlSet = if ($inPE) { 'ControlSet{0:d3}' -f [int](Get-ItemProperty "$systemHive\Select" -Name Current -ErrorAction Stop).Current } else { 'CurrentControlSet' }
        $architecture = (Get-ItemProperty "$systemHive\$controlSet\Control\Session Manager\Environment" -Name PROCESSOR_ARCHITECTURE -ErrorAction Stop).PROCESSOR_ARCHITECTURE
        $name = $current.ProductName
        if ([int]$current.CurrentBuildNumber -ge 22000 -and $name -like 'Windows 10*') { $name = $name -replace '^Windows 10','Windows 11' }
        $windows = [pscustomobject]@{ Name=$name; Edition=$current.EditionID; Version=$current.DisplayVersion; Build="$($current.CurrentBuildNumber).$($current.UBR)"; Architecture=$architecture }
    }
    catch { $errors.Add("Windows information: $($_.Exception.Message)") }
    $reboot = [Collections.Generic.List[string]]::new()
    try {
        foreach ($entry in @(@{Path="$software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending";Name='Component servicing'},@{Path="$software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired";Name='Windows Update'})) {
            if (Test-Path -LiteralPath $entry.Path -ErrorAction Stop) { $reboot.Add($entry.Name) }
        }
        if ($controlSet) {
            $session = Get-ItemProperty "$systemHive\$controlSet\Control\Session Manager" -ErrorAction Stop
            if ($session.PendingFileRenameOperations -or $session.PendingFileRenameOperations2) { $reboot.Add('Pending file rename operations') }
        }
    }
    catch { $errors.Add("Reboot indicators: $($_.Exception.Message)") }
    $atomVersion = $null
    try {
        if (!$AtomRoot) { $AtomRoot = if ($atomPath) { $atomPath } else { Join-Path $PSScriptRoot '../..' } }
        $atomVersion = (Import-PowerShellDataFile (Join-Path $AtomRoot 'Config/Version.psd1') -ErrorAction Stop).Version
    }
    catch { $errors.Add("ATOM version: $($_.Exception.Message)") }
    $system = & $query Win32_ComputerSystem @('Manufacturer','Model','TotalPhysicalMemory','NumberOfLogicalProcessors')
    $product = & $query Win32_ComputerSystemProduct @('IdentifyingNumber')
    $boards = @(& $query Win32_BaseBoard @('Manufacturer','Product','SerialNumber'))
    $bios = & $query Win32_BIOS @('Manufacturer','SMBIOSBIOSVersion','ReleaseDate')
    $enclosure = & $query Win32_SystemEnclosure @('ChassisTypes')
    $batteries = @(& $query Win32_Battery @('DeviceID'))
    $processors = @(& $query Win32_Processor @('Name','NumberOfCores','NumberOfLogicalProcessors','MaxClockSpeed'))
    $memory = @(& $query Win32_PhysicalMemory @('DeviceLocator','BankLabel','Manufacturer','PartNumber','Capacity','Speed','ConfiguredClockSpeed'))
    $graphics = @(& $query Win32_VideoController @('Name','PNPDeviceID','DriverVersion'))
    $disks = @(& $query Win32_DiskDrive @('Index','Model','Size','SerialNumber','InterfaceType','MediaType','PNPDeviceID') | Where-Object {
        $_.MediaType -eq 'Fixed hard disk media' -and $_.InterfaceType -ne 'USB' -and $_.PNPDeviceID -notmatch '^USB'
    })
    $cleanSerial = {
        param($Value)
        $serial = ([string]$Value).Trim()
        if (!$serial -or $serial -in 'Default string','To be filled by O.E.M.','To Be Filled By OEM','Unknown','None') { return $null }
        return $serial
    }
    $physical = @(& $query MSFT_PhysicalDisk @('DeviceId','BusType','MediaType') 'root/Microsoft/Windows/Storage')
    $partitions = @(& $query MSFT_Partition @('DiskNumber','AccessPaths') 'root/Microsoft/Windows/Storage')
    $volumes = @(& $query MSFT_Volume @('Path','Size','SizeRemaining') 'root/Microsoft/Windows/Storage')
    $bitLocker = [pscustomobject]@{ Volumes=$null; UnavailableReason=$null }
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    try {
        $principal = [Security.Principal.WindowsPrincipal]::new($identity)
        if (!$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            $bitLocker.UnavailableReason = 'Administrator privileges are required'
        }
        else {
            $encryptedVolumes = @(Get-CimInstance -Namespace root/cimv2/Security/MicrosoftVolumeEncryption -ClassName Win32_EncryptableVolume -Property DeviceID,DriveLetter,ConversionStatus,EncryptionMethod,IsVolumeInitializedForProtection,ProtectionStatus -OperationTimeoutSec 2 -ErrorAction Stop)
            $bitLocker.Volumes = @(foreach ($volume in $encryptedVolumes) {
                $lockStatus = $null
                try {
                    $lock = Invoke-CimMethod -InputObject $volume -MethodName GetLockStatus -OperationTimeoutSec 2 -ErrorAction Stop
                    if ($lock.ReturnValue -eq 0) { $lockStatus = $lock.LockStatus }
                    else { $errors.Add("BitLocker lock status for $($volume.DriveLetter): code $($lock.ReturnValue)") }
                }
                catch { $errors.Add("BitLocker lock status for $($volume.DriveLetter): $($_.Exception.Message)") }
                [pscustomobject]@{
                    DeviceID = $volume.DeviceID
                    DriveLetter = $volume.DriveLetter
                    ConversionStatus = $volume.ConversionStatus
                    EncryptionStatus = switch ($volume.ConversionStatus) { 0 { 'Fully decrypted' } 1 { 'Fully encrypted' } 2 { 'Encryption in progress' } 3 { 'Decryption in progress' } 4 { 'Encryption paused' } 5 { 'Decryption paused' } default { 'Unknown' } }
                    EncryptionMethod = $volume.EncryptionMethod
                    IsVolumeInitializedForProtection = $volume.IsVolumeInitializedForProtection
                    ProtectionStatus = $volume.ProtectionStatus
                    LockStatus = $lockStatus
                }
            })
        }
    }
    catch { $bitLocker.UnavailableReason = $_.Exception.Message }
    finally { $identity.Dispose() }
    $driveInventory = @(foreach ($disk in $disks) {
        $storage = $physical | Where-Object { $_.DeviceId -eq [string]$disk.Index } | Select-Object -First 1
        if ($storage.BusType -in 7,12,13,15) { continue }
        $technology = if ($storage.MediaType -eq 3) { 'HDD' }
        elseif ($storage.MediaType -eq 4 -and $storage.BusType -eq 17) { 'NVMe SSD' }
        elseif ($storage.MediaType -eq 4 -and $storage.BusType -in 3,11) { 'SATA SSD' }
        elseif ($storage.MediaType -eq 4) { 'SSD' }
        else { $null }
        $paths = @($partitions | Where-Object DiskNumber -eq $disk.Index | ForEach-Object { $_.AccessPaths })
        $readable = @($volumes | Where-Object { $_.Path -in $paths -and $null -ne $_.Size -and $null -ne $_.SizeRemaining -and $_.Size -gt 0 })
        $used = if ($readable.Count) { [Math]::Round((($readable | ForEach-Object { [double]$_.Size - [double]$_.SizeRemaining } | Measure-Object -Sum).Sum) / 1MB, 2) } else { $null }
        [pscustomobject]@{
            Model = ([string]$disk.Model).Trim()
            TotalCapacityMB = if ($null -ne $disk.Size) { [Math]::Round($disk.Size / 1MB, 2) } else { $null }
            UsedCapacityMB = $used
            FreeCapacityMB = if ($readable.Count) { [Math]::Round((($readable | Measure-Object -Property SizeRemaining -Sum).Sum) / 1MB, 2) } else { $null }
            SerialNumber = & $cleanSerial $disk.SerialNumber
            Technology = $technology
        }
    })
    $chassis = @($enclosure | ForEach-Object { $_.ChassisTypes })
    $type = if (@($chassis | Where-Object { $_ -in 8,9,10,11,14,30,31,32 }).Count -or $batteries.Count) { 'Portable' }
    elseif (@($chassis | Where-Object { $_ -in 3,4,5,6,7,15,16,23 }).Count) { 'Desktop' }
    else { 'Unknown' }
    [pscustomobject]@{
        CollectedUtc = [datetime]::UtcNow.ToString('o')
        AtomVersion = $atomVersion
        ExecutionContext = [pscustomobject]@{ Environment=$(if ($inPE) { 'Windows PE/RE' } else { 'Windows' }); TargetDrive=$target }
        Windows = $windows
        PendingRebootIndicators = $reboot.ToArray()
        BitLocker = $bitLocker
        Manufacturer = $system.Manufacturer
        Model = $system.Model
        SerialNumber = & $cleanSerial $product.IdentifyingNumber
        FormFactor = $type
        BatteryDetected = [bool]$batteries.Count
        Motherboards = @(foreach ($board in $boards) {
            [pscustomobject]@{ Manufacturer=$board.Manufacturer; Product=$board.Product; SerialNumber=$(& $cleanSerial $board.SerialNumber) }
        })
        BIOS = if ($bios) { [pscustomobject]@{ Manufacturer=$bios.Manufacturer; Version=$bios.SMBIOSBIOSVersion; ReleasedUtc=$(if ($bios.ReleaseDate) { ([datetime]$bios.ReleaseDate).ToUniversalTime().ToString('o') }) } } else { $null }
        Processors = @($processors | Select-Object @{Name='Model';Expression={$_.Name.Trim()}},NumberOfCores,NumberOfLogicalProcessors,@{Name='MaxClockSpeedMHz';Expression={$_.MaxClockSpeed}})
        Memory = [pscustomobject]@{
            TotalCapacityMB = if ($null -ne $system.TotalPhysicalMemory) { [Math]::Round($system.TotalPhysicalMemory / 1MB, 2) } else { $null }
            PopulatedModules = $memory.Count
            Modules = @($memory | Select-Object DeviceLocator,BankLabel,Manufacturer,@{Name='PartNumber';Expression={([string]$_.PartNumber).Trim()}},@{Name='CapacityMB';Expression={if ($null -ne $_.Capacity) { [Math]::Round($_.Capacity / 1MB, 2) }}},@{Name='RatedSpeedMHz';Expression={$_.Speed}},@{Name='ConfiguredSpeedMHz';Expression={$_.ConfiguredClockSpeed}})
        }
        Graphics = @($graphics | Select-Object Name,PNPDeviceID,DriverVersion)
        Drives = $driveInventory
        Unavailable = $errors.ToArray()
    }
}
