$programs = [ordered]@{

'7-Zip' = @{
    Id        = 'c03989896863440a90ae0e537e0aafc4'
    Category  = 'Data Services'
    Tags      = @('Files', 'Compression', 'Utilities')
    Aliases   = @('7zip')
    Silent    = $true
    ToolTip   = "File management, compression, & extraction"
    Description = 'Create and extract compressed archives, or browse their contents without unpacking everything. Manage files and folders, choose compression settings, and protect supported archive formats with a password.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\7-Zip"
        RelativePath    = "7zFM.exe"
        Scoop           = 'main/7zip'
        ScriptBlock     = {
            # Administrative extraction avoids installing 7-Zip or using it to update itself.
            $stagePath = Join-Path ([IO.Path]::GetTempPath()) ('ATOM-7Zip-MSI-' + [Guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $stagePath -ErrorAction Stop | Out-Null
            $msiLog = Join-Path $stagePath 'extract.log'
            try {
                $archive = Copy-ProgramItem @downloadParams -OutFile "$stagePath\" -ErrorAction Stop
                if ($archive.Extension -ne '.msi') { throw 'Expected a 7-Zip MSI package.' }
                $extractPath = Join-Path $stagePath 'Extracted'
                if ($progressState) { $progressState.Status = 'Extracting 7-Zip' }
                $msiProcess = Start-Process -FilePath "$env:SystemRoot\System32\msiexec.exe" -ArgumentList "/a `"$($archive.FullName)`" /qn /norestart TARGETDIR=`"$extractPath`" /L*v `"$msiLog`"" -WindowStyle Hidden -Wait -PassThru -ErrorAction Stop
                if ($msiProcess.ExitCode -notin 0, 3010) { throw "MSI extraction failed (exit $($msiProcess.ExitCode))." }
                $payloadPath = Join-Path $extractPath 'Files\7-Zip'
                foreach ($requiredFile in '7z.exe', '7z.dll', '7zFM.exe') {
                    if (![IO.File]::Exists((Join-Path $payloadPath $requiredFile))) { throw "7-Zip package is missing $requiredFile." }
                }
                New-Item -ItemType Directory -Path $destinationPath -Force -ErrorAction Stop | Out-Null
                Get-ChildItem -LiteralPath $payloadPath -Force | Copy-Item -Destination $destinationPath -Recurse -Force -ErrorAction Stop
            } catch {
                Write-Verbose "7-Zip setup details retained in '$stagePath': $($_.Exception.Message)"
                throw "7-Zip setup failed: $($_.Exception.Message) Log: $msiLog"
            }
            Remove-Item -LiteralPath $stagePath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

'AnyBurn' = @{
    Id        = '493a04d12ad341a0a9158313e0447c20'
    Category  = 'Data Services'
    Tags      = @('Storage', 'Optical Media', 'ISO')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "CD/DVD & ISO burning software"
    Description = 'Create, copy, and burn disc images for CDs, DVDs, and Blu-ray media. Convert image formats or extract files from an ISO when you need to inspect or prepare installation media.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\AnyBurn"
        RelativePath    = '\AnyBurn(64-bit)\AnyBurn.exe'
        Scoop           = 'extras/anyburn'
        Uri             = 'https://www.anyburn.com/anyburn.zip'
    }
}

'ATOM Notes' = @{
    Id        = '3cbd4ed7dc4f45e6bcf3213a00fca93e'
    Category  = 'Misc'
    Tags      = @('Productivity', 'Notes', 'Utilities')
    Silent    = $true
    ToolTip   = "Take notes during PC repair"
    Description = 'Record symptoms, repair steps, and follow-up tasks in a simple text editor. Keep a running account of your work while moving between diagnostic and repair tools.'
    WorksInOs = $true
    WorksInPe = $true
}

'ATOMizer' = @{
    Id        = '32e53a4c8b47466289a0bfc843532ded'
    Category  = 'Data Services'
    Tags      = @('Storage', 'USB', 'Deployment')
    Silent    = $true
    ToolTip   = "Format/update multiple flash drives w/ zip & ISO files"
    Description = 'Prepare multiple USB drives with selected ZIP and ISO files in one workflow. Format new drives or update existing ones to maintain a consistent set of installation and repair media.'
    WorksInOs = $true
    WorksInPe = $true
}
    
'Autoruns'  = @{
    Id        = '9efcd67d94694060b5d97cb0f432cb87'
    Category  = 'Repair & Tune'
    Tags      = @('System', 'Startup', 'Diagnostics')
    Silent    = $true
    ToolTip   = "View/modify all computer startups"
    Description = 'Inspect programs, services, drivers, and other components configured to start automatically. Disable individual entries to investigate slow startup, unwanted software, or persistent background activity.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\Autoruns"
        RelativePath    = 'Autoruns64.exe'
        Scoop           = 'sysinternals/autoruns'
        Uri             = 'https://download.sysinternals.com/files/Autoruns.zip'
    }
}

'BlueScreenView' = @{
    Id        = '4a83e69d88cd422abea8beb422d95ffa'
    Category  = 'Diagnostics'
    Tags      = @('Diagnostics', 'Crash Analysis', 'Logs')
    Silent    = $true
    ToolTip   = "View blue screen crash dumps"
    Description = 'Review saved blue screen crash dumps, including stop codes and the drivers present during each crash. Compare incidents to identify recurring patterns and narrow down possible causes of instability.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\BlueScreenView"
        RelativePath    = 'BlueScreenView.exe'
        Scoop           = 'nirsoft/bluescreenview'
        Uri             ='https://www.nirsoft.net/utils/bluescreenview-x64.zip'
    }
}

'Bulk App Installer' = @{
    Id        = '07ee38f87eff441bafe87143eab66ac1'
    Category  = 'Repair & Tune'
    Tags      = @('Deployment', 'Setup', 'Automation')
    Silent    = $true
    ToolTip   = "Bulk-install apps from package managers & download URLs"
    Description = 'Queue multiple applications for installation through package managers or direct download links. Choose an installation method and follow progress in one place when setting up or refreshing a computer.'
    WorksInOs = $true
    WorksInPe = $false
}

'ClamAV' = @{
    Id        = 'a603782e4bf84b89b85d94daada472bc'
    Category  = 'AV Scanners'
    Tags      = @('Security', 'Antivirus', 'Scanner')
    Silent    = $true
    ArgumentList = '-Interactive'
    ToolTip   = 'Portable command-line malware scanner'
    Description = 'Scan the Windows folder or its entire drive using local malware definitions. Review detections in a saved report without automatically removing files; mounted Windows installations can also be scanned from PE.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\ClamAV"
        RelativePath    = 'clamav-*\clamscan.exe'
        Scoop           = 'extras/clamav'
    }
}

'Command Prompt' = @{
    Id        = '149ef50b3de547d38727244a49aabd43'
    Category  = 'Windows Shortcuts'
    Tags      = @('System', 'Terminal', 'Command Line')
    Aliases   = @('cmd','terminal')
    Silent    = $true
    ToolTip   = "Windows legacy command-line"
    Description = 'Run Windows commands, batch files, and command-line repair utilities. Use the traditional shell for tasks such as checking network connectivity, inspecting disks, or troubleshooting system files.'
    WorksInOs = $true
    WorksInPe = $true
}

'Control Panel' = @{
    Id        = 'a399d2681fe94c788dfb923f762c25d2'
    Category  = 'Windows Shortcuts'
    Tags      = @('System', 'Settings', 'Windows')
    Silent    = $true
    ToolTip   = "Windows legacy Control Panel"
    Description = 'Access traditional Windows configuration tools for devices, networking, accounts, and software. Find detailed system options and older configuration dialogs that may be separate from the Settings app.'
    WorksInOs = $true
    WorksInPe = $false
}

'CPU-Z' = @{
    Id        = '1ed2c25d1f5747f79ee54a28bded0d54'
    Category  = 'Diagnostics'
    Tags      = @('Hardware', 'Diagnostics', 'Benchmark')
    Silent    = $true
    ToolTip   = "View CPU info, benchmarking, & stress testing"
    Description = 'Inspect processor specifications, motherboard details, and memory configuration, including module information. Run the built-in CPU benchmark or stress test to compare performance and investigate stability.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\CPU-Z"
        RelativePath    = 'cpuz_x64.exe'
        Scoop           = 'extras/cpu-z'
        Uri             = 'https://download.cpuid.com/cpu-z/cpu-z_2.12-en.zip'
    }
}

'CrystalDiskInfo' = @{
    Id        = 'd09aba496a414b1794abf696a9dc849e'
    Category  = 'Diagnostics'
    Tags      = @('Storage', 'Diagnostics', 'Health')
    Silent    = $true
    ToolTip   = "View drive health & info"
    Description = 'Review drive temperatures, interface details, and S.M.A.R.T. health information. Look for warning indicators and abnormal readings when investigating storage reliability or planning a drive replacement.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\CrystalDiskInfo"
        RelativePath    = 'DiskInfo64.exe'
        Scoop           = 'extras/crystaldiskinfo'
        Uri             = 'https://crystalmark.info/download/zz/CrystalDiskInfo9_4_3.zip'
    }
}

'CrystalDiskMark' = @{
    Id        = '5200ff7851b34c6a88f9ac315df63f1e'
    Category  = 'Diagnostics'
    Tags      = @('Storage', 'Benchmark', 'Diagnostics')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "Test drive read/write speeds"
    Description = 'Measure sequential and random read and write speeds on a selected drive. Compare storage performance across devices or check whether a drive is delivering the speeds expected for its connection.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\CrystalDiskMark"
        RelativePath    = 'DiskMark64.exe'
        Scoop           = 'extras/crystaldiskmark'
        Uri             = 'https://crystalmark.info/download/zz/CrystalDiskMark8_0_4c.zip'
    }
}

'Device Manager' = @{
    Id        = '7baf54ba341a412e873fd3cc3b195f52'
    Category  = 'Windows Shortcuts'
    Tags      = @('Hardware', 'Drivers', 'System')
    Silent    = $true
    ToolTip   = "View & manage device info & drivers"
    Description = 'Inspect detected hardware, device status, and installed drivers. Update, roll back, disable, or uninstall devices when troubleshooting missing hardware, driver conflicts, or malfunctioning peripherals.'
    WorksInOs = $true
    WorksInPe = $false
}

'Disk Management' = @{
    Id        = 'acf49174abd84ba8acc9021f6cd7cde9'
    Category  = 'Windows Shortcuts'
    Tags      = @('Storage', 'Disk', 'System')
    Silent    = $true
    ToolTip   = "Manage local drives"
    Description = 'Inspect disks, partitions, drive letters, and available unallocated space. Create or format volumes, change drive letters, and extend or shrink supported partitions when organizing local storage.'
    WorksInOs = $true
    WorksInPe = $true
}

'Display Driver Uninstaller' = @{
    Id        = 'ee4e4bcf565d44dab40efa2c9f69923c'
    Category  = 'Repair & Tune'
    Tags      = @('Drivers', 'Graphics', 'Cleanup')
    Aliases   = @('DDU')
    Silent    = $true
    ToolTip   = "Completely remove GPU drivers"
    Description = 'Remove graphics drivers and associated files, settings, and registry entries. Prepare for a clean driver installation when resolving display problems or switching between graphics hardware vendors.'
    WorksInOs = $true
    WorksInPe = $false
    ProgramInfo = @{
        DestinationPath = "$programsPath\Display Driver Uninstaller"
        RelativePath    = 'Display Driver Uninstaller.exe'
        Scoop           = 'extras/ddu'
        Uri             = 'https://www.wagnardsoft.com/DDU/download/DDU%20v18.0.8.9.exe'
        ScriptBlock     = {
            $extractPath = Join-Path $destinationPath '.extract'
            if (Test-Path -LiteralPath $extractPath) { Remove-Item -LiteralPath $extractPath -Recurse -Force }
            New-Item -Path $extractPath -ItemType Directory -Force | Out-Null

            Copy-ProgramItem @downloadParams | Expand-With7z -DestinationPath $extractPath -Cleanup
            $detectedExe = Get-ChildItem -LiteralPath $extractPath -Filter 'Display Driver Uninstaller.exe' -Recurse | Select-Object -First 1
            if (!$detectedExe) { throw 'The DDU executable was not found in the downloaded archive.' }

            if (!(Test-Path -LiteralPath $destinationPath)) {
                New-Item -Path $destinationPath -ItemType Directory -Force | Out-Null
            }
            Get-ChildItem -LiteralPath $detectedExe.Directory.FullName -Force | Move-Item -Destination $destinationPath -Force
            Remove-Item -LiteralPath $extractPath -Recurse -Force
        }
    }
}

'Emsisoft Emergency Kit' = @{
    Id        = '8b17189d2f104b83aa350fa70d50460e'
    Category  = 'AV Scanners'
    Tags      = @('Security', 'Antivirus', 'Scanner')
    Silent    = $true
    ToolTip   = "Portable dual-engine malware scanner"
    Description = 'Scan files and drives for malware with a portable, on-demand scanner. Review detections and quarantine or remove suspicious items when investigating an infection without installing a full security suite.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\Emsisoft Emergency Kit"
        RelativePath    = 'bin64\a2emergencykit.exe'
        Uri             = 'https://dl.emsisoft.com/EmsisoftEmergencyKit.exe'
        ScriptBlock     = {
            Copy-ProgramItem @downloadParams | Expand-With7z -DestinationPath $destinationPath -Cleanup
        }
    }
}

'Event Viewer' = @{
    Id        = '7c564a322e164483987903fffa651f99'
    Category  = 'Windows Shortcuts'
    Tags      = @('System', 'Logs', 'Diagnostics')
    Silent    = $true
    ToolTip   = "View Windows event logs"
    Description = 'Browse Windows application, security, and system event logs. Filter by time, source, or severity to connect errors and warnings with crashes, failed services, or other reported problems.'
    WorksInOs = $true
    WorksInPe = $false
}

'Everything' = @{
    Id        = 'bb9dbb5c268c4531b3e7760d19cd2864'
    Category  = 'Data Services'
    Tags      = @('Files', 'Search', 'Utilities')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "Instantly locate files and folders"
    Description = 'Locate files and folders quickly by searching an indexed list of names and paths. Use filters and search expressions to narrow large result sets when you know what you need but not where it is stored.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\Everything"
        RelativePath    = 'Everything.exe'
        Scoop           = 'extras/everything'
        Uri             = 'https://www.voidtools.com/Everything-1.4.1.1032.x64.zip'
    }
}

'Explorer++' = @{
    Id        = 'cfa8830822d84f2c90e362d0ac3a1113'
    Category  = 'Data Services'
    Tags      = @('Files', 'File Manager', 'Utilities')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "Alternative file explorer"
    Description = 'Browse and manage files in a lightweight explorer with multiple tabs. Keep several locations open while copying, moving, or organizing files across folders and drives.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\Explorer++"
        RelativePath    = 'Explorer++.exe'
        Scoop           = 'extras/explorerplusplus'
        Uri             = 'https://download.explorerplusplus.com/stable/1.4.0/explorerpp_x64.zip'
    }
}

'FreeCommander' = @{
    Id        = '8e4e1f64d7774d28aaf9347a9a4b5368'
    Category  = 'Data Services'
    Tags      = @('Files', 'File Manager', 'Utilities')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "Alternative file explorer"
    Description = 'Manage files in two side-by-side folder panes with support for tabs and archive browsing. Compare locations and copy or move files between them without repeatedly switching windows.'
    WorksInOs = $true
    WorksInPe = $false
    ProgramInfo = @{
        DestinationPath = "$programsPath\FreeCommander"
        RelativePath    = 'FreeCommander.exe'
        Scoop           = 'extras/freecommander'
        Uri             = 'https://freecommander.com/downloads/FreeCommanderXE-32-public_portable.zip'
    }
}

'HCI Design MemTest' = @{
    Id        = '00cc9e0adfe648ea9caa8e09792b7877'
    Category  = 'Diagnostics'
    Tags      = @('Memory', 'Diagnostics', 'Stress Test')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "Memory stability tester"
    Description = 'Test available memory from within Windows and report errors detected during the test. Check for instability after memory changes or investigate crashes that may be related to RAM.'
    WorksInOs = $true
    WorksInPe = $false
    ProgramInfo = @{
        DestinationPath = "$programsPath\HCI Design MemTest"
        RelativePath    = 'memtest.exe'
        Uri             = 'https://hcidesign.com/memtest/MemTest.zip'
    }
}

'HWiNFO' = @{
    Id        = '00fce810d89d45a0b00a2ef2a0a69559'
    Category  = 'Diagnostics'
    Tags      = @('Hardware', 'Monitoring', 'Diagnostics')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "Detailed hardware information and monitoring"
    Description = 'Inspect detailed hardware specifications and monitor live readings from supported sensors. Track temperatures, clock speeds, power use, and other measurements while diagnosing performance or cooling problems.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\HWiNFO"
        RelativePath    = 'HWiNFO64.exe'
        Scoop           = 'extras/hwinfo'
        Uri             = 'https://www.sac.sk/download/utildiag/hwi_850.zip'
    }
}

'HWMonitor' = @{
    Id        = 'ab721886544b4aa0917d0a3486e69cb5'
    Category  = 'Diagnostics'
    Tags      = @('Hardware', 'Monitoring', 'Diagnostics')
    Silent    = $true
    ToolTip   = "Real-time hardware monitoring"
    Description = 'Display temperatures, voltages, fan speeds, and other readings from supported hardware sensors. Watch current and recorded minimum or maximum values to spot unusual behavior during normal use or testing.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\HWMonitor"
        RelativePath    = 'HWMonitor_x64.exe'
        Scoop           = 'extras/hwmonitor'
        Uri             = 'https://download.cpuid.com/hwmonitor/hwmonitor_1.55.zip'
    }
}

'Installed Apps' = @{
    Id        = '39f4f924fd3e4148b0403c25306a0f5e'
    Category  = 'Windows Shortcuts'
    Tags      = @('Software', 'Uninstall', 'Settings')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "Windows Settings app management"
    Description = 'Review installed applications and open their available management options in Windows Settings. Uninstall unwanted software, or access repair and reset options for applications that support them.'
    WorksInOs = $true
    WorksInPe = $false
}

'KeyCutlass' = @{
    Id        = 'cfe7a34bcfa54a21a68a69d02dd0db5a'
    Category  = 'Misc'
    Tags      = @('Security', 'Keys', 'Recovery')
    Silent    = $true
    ToolTip   = "View Windows product & encryption keys"
    Description = 'Display Windows product keys found in firmware and registry data, along with available encryption recovery information. Copy relevant keys for service work; some reported product keys may be generic or inaccurate.'
    WorksInOs = $true
    WorksInPe = $true
}

'LibreWolf' = @{
    Id        = '10a87fcf01fd4ac4b9b036ce04a2cd4d'
    Category  = 'Misc'
    Tags      = @('Browser', 'Internet', 'Privacy')
    Silent    = $true
    ToolTip   = "Privacy-focused portable web browser"
    Description = 'Browse the web with a Firefox-based browser configured to emphasize privacy and limit telemetry. Access support sites, documentation, and downloads in a portable browsing environment.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\LibreWolf"
        RelativePath    = 'LibreWolf\librewolf.exe'
        ArgumentList    = "-profile `"$programsPath\LibreWolf\Profiles\Default`" -no-remote"
        Scoop           = 'extras/librewolf'
        Uri             = 'https://librewolf.dev/api/packages/librewolf/generic/librewolf/153.0.4-1/librewolf-153.0.4-1-windows-x86_64-portable.zip'
        ScriptBlock     = {
            $extractPath = "${destinationPath}.extract"
            if (Test-Path -LiteralPath $extractPath) { Remove-Item -LiteralPath $extractPath -Recurse -Force }

            $archive = Copy-ProgramItem @downloadParams
            Expand-Archive -LiteralPath $archive.FullName -DestinationPath $extractPath -Force
            Remove-Item -LiteralPath $archive.FullName -Force
            $executable = Get-ChildItem -LiteralPath $extractPath -Filter 'LibreWolf-Portable.exe' -Recurse | Select-Object -First 1
            if (!$executable) { throw 'Unable to locate the LibreWolf portable package root in the downloaded archive.' }

            if (!(Test-Path -LiteralPath $destinationPath)) {
                New-Item -Path $destinationPath -ItemType Directory -Force | Out-Null
            }
            Get-ChildItem -LiteralPath $executable.DirectoryName -Force | Copy-Item -Destination $destinationPath -Recurse -Force
            Remove-Item -LiteralPath $extractPath -Recurse -Force
        }
    }
}

'MalwareBytes AdwCleaner' = @{
    Id        = 'e890cb8037d6464cbb42508b8fdf34c1'
    Category  = 'AV Scanners'
    Tags      = @('Security', 'Antivirus', 'Scanner')
    Aliases   = @('MBAM')
    Silent    = $true
    ToolTip   = "MBAM malware scanner"
    Description = 'Scan for adware, browser hijackers, and potentially unwanted software. Review detections and clean up components that alter browser behavior, display unwanted advertising, or bundle unwanted applications.'
    WorksInOs = $true
    WorksInPe = $false
    ProgramInfo = @{
        DestinationPath = "$programsPath\MalwareBytes AdwCleaner"
        RelativePath    = 'adwcleaner.exe'
        Scoop           = 'extras/adwcleaner'
        Uri             = 'https://adwcleaner.malwarebytes.com/adwcleaner?channel=release'
    }
}

'Trellix Stinger' = @{
    Id        = 'bd4e6ef985924fd4bdf83bc719454e9e'
    Category  = 'AV Scanners'
    Tags      = @('Security', 'Antivirus', 'Scanner')
    Silent    = $true
    ToolTip   = "Trellix AV scanner (formerly McAfee)"
    Description = 'Run an on-demand scan for specific malware threats using a standalone removal utility. Use targeted detection and cleanup when investigating a suspected infection alongside other diagnostic tools.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\Stinger"
        RelativePath    = 'stinger64.exe'
        Uri             = 'https://downloadcenter.trellix.com/products/mcafee-avert/Stinger/stinger64.exe'
    }
}

'MemTest86' = @{
    Id        = '88739528a7db4b3a8c4b007da805c673'
    Category  = 'Diagnostics'
    Tags      = @('Memory', 'Diagnostics', 'Bootable')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "Bootable memory tester"
    Description = 'Prepare bootable media for testing RAM outside Windows. Run independent memory checks when investigating unexplained crashes, data corruption, or stability problems that persist across operating systems.'
    WorksInOs = $true
    WorksInPe = $false
    ProgramInfo = @{
        DestinationPath = "$programsPath\MemTest86"
        RelativePath    = 'imageUSB.exe'
        Uri             = 'https://www.memtest86.com/downloads/memtest86-usb.zip'
    }
}

'Microsoft Safety Scanner' = @{
    Id        = '9093eeb59c25483a85378fea2c6dfc07'
    Category  = 'AV Scanners'
    Tags      = @('Security', 'Antivirus', 'Scanner')
    Aliases   = @('MSERT', 'Microsoft Security Scanner')
    Silent    = $true
    ToolTip   = 'Microsoft portable malware scanner'
    Description = 'Find and remove malware using Microsoft''s portable scanner with quick, full, or custom scans. The download expires after 10 days and must be downloaded again to refresh its definitions.'
    WorksInOs = $true
    WorksInPe = $false
    ProgramInfo = @{
        DestinationPath = "$programsPath\Microsoft Safety Scanner"
        RelativePath    = 'msert.exe'
        Uri             = 'https://go.microsoft.com/fwlink/?LinkId=212732'
    }
}

'MountOS' = @{
    Id        = '6865de6b4f8f45e78840176c7d6813d1'
    Category  = 'Misc'
    Tags      = @('Recovery', 'Registry', 'Offline')
    Silent    = $true
    ToolTip   = "Mount offline registry hives for OS modification"
    Description = 'Select an offline Windows installation and mount its registry hives for repair tools to use. Unlock an encrypted volume with its recovery key when needed before working on the installed operating system.'
    WorksInOs = $false
    WorksInPe = $true
}

'MSI Kombustor' = @{
    Id        = '13d88db8dac444cfb1033c4d6a69cc97'
    Category  = 'Diagnostics'
    Tags      = @('Graphics', 'Stress Test', 'Benchmark')
    Silent    = $true
    ToolTip   = "GPU stress-tester"
    Description = 'Place the graphics processor under a sustained rendering workload to test stability and cooling. Watch for visual artifacts, excessive temperatures, or crashes while evaluating graphics hardware.'
    WorksInOs = $true
    WorksInPe = $false
    ProgramInfo = @{
        DestinationPath = "$programsPath\MSI Kombustor"
        RelativePath    = 'MSI-Kombustor-x64.exe'
        Scoop           = 'extras/msikombustor'
        Uri             = 'https://gpuscore.top/msi/MSI_Kombustor4_Setup_v4.1.33.0_x64.exe'
        ScriptBlock     = {
            $outfile = Copy-ProgramItem @downloadParams -OutFile "$env:TEMP\"
            Start-Process $outfile -ArgumentList "/VERYSILENT /DIR=`"$destinationPath`" /NOICONS /NORESTART" -WorkingDirectory $outfile.DirectoryName -Wait -PassThru

            @(
                $outfile,
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{F3D3CC6B-9AD7-4F43-8C69-40D5902FDC5C}}_is1",
                (Join-Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)) "MSI Kombustor 4 x64.lnk")
            ) | ForEach-Object {
                Remove-Item -Path $_ -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

'Norton Power Eraser' = @{
    Id        = '0711725fc0c741f5889f889860cc2d68'
    Category  = 'AV Scanners'
    Tags      = @('Security', 'Antivirus', 'Scanner')
    Aliases   = @('NPE')
    Silent    = $true
    ToolTip   = "Norton AV scanner"
    Description = 'Run an aggressive on-demand scan for difficult-to-remove threats and suspicious software. Review the findings carefully before removal, since legitimate applications can also be flagged.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\Norton Power Eraser"
        RelativePath    = 'NPE.exe'
        Uri             = 'https://www.norton.com/npe_latest'
    }
}

'Notepad++' = @{
    Id        = '2135d54a0024411c932097fc5d7f110e'
    Category  = 'Misc'
    Tags      = @('Text Editor', 'Development', 'Productivity')
    Aliases   = @('n++')
    Silent    = $true
    ToolTip   = "Notepad but with two pluses"
    Description = 'Edit text files, scripts, and configuration files with tabs, syntax highlighting, and advanced search. Work across multiple documents or locate and replace matching text throughout a folder.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\Notepad++"
        RelativePath    = 'notepad++.exe'
        Scoop           = 'extras/notepadplusplus'
        Uri             = 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.7.4/npp.8.7.4.portable.x64.zip'
    }
}

'O&O Shutup10++' = @{
    Id        = '120a1ff1bc93468ab9fd988a7fe35b0e'
    Category  = 'Repair & Tune'
    Tags      = @('Privacy', 'Tweaks', 'Security')
    Silent    = $true
    ToolTip   = "Thorough telemetry disabler"
    Description = 'Review and change Windows privacy, telemetry, and related system settings from one interface. Apply individual options or recommended groups to control data sharing and selected Windows features.'
    WorksInOs = $true
    WorksInPe = $false
    ProgramInfo = @{
        DestinationPath = "$programsPath\O&O Shutup10++"
        RelativePath    = 'OOSU10.exe'
        Scoop           = 'extras/shutup10'
        Uri             = 'https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe'
    }
}

'OCCT' = @{
    Id        = 'fc44d2ac1a684d8bb21596f85098d9a6'
    Category  = 'Diagnostics'
    Tags      = @('Hardware', 'Diagnostics', 'Stress Test')
    Silent    = $true
    ToolTip   = "All-in-one diagnostic, stability, & stress-tester"
    Description = 'Test CPU, memory, graphics, and combined system stability under controlled workloads. Monitor sensor readings and reported errors to investigate crashes, thermal problems, or unstable hardware settings.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\OCCT"
        RelativePath    = 'OCCT.exe'
        Uri             = 'https://www.ocbase.com/download/edition:Personal'
    }
}

'OneCommander' = @{
    Id        = '7fae09fe4a74410f9794e653ee0a78ea'
    Category  = 'Data Services'
    Tags      = @('Files', 'File Manager', 'Utilities')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "Alternative file explorer"
    Description = 'Browse and organize files using a modern interface with tabs and dual-pane navigation. Keep source and destination folders visible while moving files or working across multiple locations.'
    WorksInOs = $true
    WorksInPe = $false
    ProgramInfo = @{
        DestinationPath = "$programsPath\OneCommander"
        RelativePath    = 'OneCommander.exe'
        Scoop           = 'extras/onecommander'
        Uri             = 'https://onecommander.com/OneCommander3.93.0.0.zip'
    }
}

'Opera' = @{
    Id        = 'fba4ab8002af4a3c81269a83757cddb5'
    Category  = 'Misc'
    Tags      = @('Browser', 'Internet', 'Media')
    Silent    = $true
    ToolTip   = "Portable web browser"
    Description = 'Browse websites, access online tools, and download files in a portable browser. Keep multiple pages open in tabs while consulting support resources or testing access to web services.'
    WorksInOs = $true
    WorksInPe = $false
    # PE experiment: UI rendered with SwiftShader, then crashed with a GPU command-buffer failure; mf.dll was also unavailable.
    # PeArgumentList = '--no-sandbox --disable-gpu-sandbox --use-angle=swiftshader --enable-unsafe-swiftshader --disable-breakpad --no-first-run'
    ProgramInfo = @{
        DestinationPath = "$programsPath\Opera"
        RelativePath    = 'Opera.exe'
        Scoop           = 'extras/opera'
        Uri             = 'https://net.geo.opera.com/opera_portable'
        ScriptBlock     = {
            $outfile = Copy-ProgramItem @downloadParams -OutFile "$env:TEMP\"
            Start-Process $outfile -ArgumentList "--silent --installfolder=`"$destinationPath`" --singleprofile=1 --copyonly=1 --launchbrowser=0" -Wait
            Remove-Item $outfile -Force
        }
    }
}

'Orca' = @{
    Id        = 'ec45cd5750ef4e56b901fea4f874da1c'
    Category  = 'Misc'
    Tags      = @('Installer', 'Development', 'Utilities')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "Official Microsoft tool to analyze and modify MSIs"
    Description = 'Inspect and edit the tables inside Windows Installer MSI packages. Examine installation properties, components, and actions, or create transforms to customize a package for deployment.'
    WorksInOs = $true
    WorksInPe = $false
    ProgramInfo = @{
        DestinationPath = "$programsPath\Orca"
        RelativePath    = '\Orca\orca.exe'
        Uri             = 'https://download.microsoft.com/download/4/2/2/42245968-6A79-4DA7-A5FB-08C0AD0AE661/windowssdk/Installers/Orca-x86_en-us.msi'
        ScriptBlock     = {
            $files = (
                $programs.Orca.ProgramInfo.Uri,
                "https://download.microsoft.com/download/4/2/2/42245968-6A79-4DA7-A5FB-08C0AD0AE661/windowssdk/Installers/838060235bcd28bf40ef7532c50ee032.cab",
                "https://download.microsoft.com/download/4/2/2/42245968-6A79-4DA7-A5FB-08C0AD0AE661/windowssdk/Installers/a35cd6c9233b6ba3da66eecaa9190436.cab",
                "https://download.microsoft.com/download/4/2/2/42245968-6A79-4DA7-A5FB-08C0AD0AE661/windowssdk/Installers/fe38b2fd0d440e3c6740b626f51a22fc.cab"
            )
            
            $downloadedFiles = $files | ForEach-Object {
                Copy-WebItem -Uri $_ -ProgressState $progressState
            }

            Start-Process msiexec -ArgumentList "/a $($downloadedFiles[0]) /qn TARGETDIR=$destinationPath" -Wait

            $downloadedFiles | ForEach-Object {
                Remove-Item $_ -Force
            }
        }
    }
}

'Ornstein and S-Mode' = @{
    Id        = '32948b44a6bc4e37bc6193b81e6f3676'
    Category  = 'Misc'
    Tags      = @('System', 'Settings', 'Windows')
    Silent    = $true
    ToolTip   = "Disable Windows S-Mode"
    Description = 'Disable the S-mode restriction on a Windows installation so it can run applications from outside the Microsoft Store. Use this during system preparation when conventional desktop tools are required.'
    WorksInOs = $true
    WorksInPe = $false
}

'PassCrack' = @{
    Id        = 'e6850a8c09b74feebd649e4773e48a33'
    Category  = 'Misc'
    Tags      = @('Recovery', 'Password', 'Offline')
    Silent    = $true
    ToolTip   = "Disable Windows login passwords (requires MountOS ran)"
    Description = 'Remove login password requirements for local Windows accounts or enable the built-in Administrator account on an offline installation. Requires its registry hives to be mounted through MountOS first.'
    WorksInOs = $false
    WorksInPe = $true
}

'PowerShell' = @{
    Id        = '1f28ada1ed1b49aca6e5b489efc047bb'
    Category  = 'Windows Shortcuts'
    Tags      = @('System', 'Terminal', 'Command Line')
    Aliases   = @('pwsh','terminal')
    Silent    = $true
    ToolTip   = "Windows modern command-line (native)"
    Description = 'Run Windows PowerShell commands and scripts for system administration and troubleshooting. Inspect structured system data, automate repeated tasks, and use modules built for the Windows PowerShell environment.'
    WorksInOs = $true
    WorksInPe = $true
}

'PowerShell Core' = @{
    Id        = '4db352bc6c7a482289eee83e232d3f00'
    Category  = 'ATOM Dependencies'
    Tags      = @('System', 'Terminal', 'Command Line')
    Aliases   = @('pwsh','terminal')
    DownloadOnly = $true
    Silent    = $true
    ToolTip   = "Windows modern command-line (non-native)"
    Description = 'Launch the newer PowerShell environment for automation and command-line administration. Run scripts and modules that require modern PowerShell features alongside the Windows-provided shell.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\PowerShell Core_x64"
        RelativePath    = 'pwsh.exe'
        Scoop           = 'main/pwsh'
        Uri             = 'https://github.com/PowerShell/PowerShell/releases/download/v7.4.6/PowerShell-7.4.6-win-x64.zip'
        ScriptBlock     = {
            ($outfile = Copy-ProgramItem @downloadParams) | Expand-Archive -DestinationPath $destinationPath -Force
            Remove-Item -Path $outfile -Force
            Copy-Item -Path $destinationPath\pwsh.exe -Destination $destinationPath\powershell.exe -Force
        }
    }
}

'Prime95' = @{
    Id        = '27c2c430bcd241528809092ae3450483'
    Category  = 'Diagnostics'
    Tags      = @('CPU', 'Stress Test', 'Diagnostics')
    Silent    = $true
    ToolTip   = "CPU stability tester"
    Description = 'Stress the processor and memory with sustained mathematical workloads. Choose torture-test settings to investigate calculation errors, overheating, or instability after hardware or configuration changes.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\Prime95"
        RelativePath    = 'prime95.exe'
        Scoop           = 'extras/prime95'
        Uri             = 'https://download.mersenne.ca/gimps/v30/30.19/p95v3019b20.win64.zip'
    }
}

'Process Explorer' = @{
    Id        = 'fc5fdcb54ce54141a05c03a44d5059fd'
    Category  = 'Repair & Tune'
    Tags      = @('System', 'Processes', 'Diagnostics')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "Inspect processes, handles, and loaded DLLs"
    Description = 'Inspect running processes, their parent-child relationships, loaded DLLs, and open handles. Identify resource-heavy applications or find which process is holding a file open.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\Process Explorer"
        RelativePath    = 'procexp64.exe'
        Scoop           = 'sysinternals/process-explorer'
        Uri             = 'https://download.sysinternals.com/files/ProcessExplorer.zip'
    }
}

'Process Monitor' = @{
    Id        = '7f8599b0957346ad9e398c5317ada947'
    Category  = 'Repair & Tune'
    Tags      = @('System', 'Monitoring', 'Diagnostics')
    Aliases   = @('ProcMon')
    Silent    = $true
    ToolTip   = "Real-time process monitoring & snapshotting"
    Description = 'Capture file system, registry, and process activity as it happens. Filter the trace to investigate access failures, missing files, unexpected registry changes, or application startup behavior.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\Process Monitor"
        RelativePath    = 'ProcMon64.exe'
        Scoop           = 'sysinternals/procmon'
        Uri             = 'https://download.sysinternals.com/files/ProcessMonitor.zip'
    }
}

'Reboot to PE' = @{
    Id        = '1e2c59eea4554c7b8dbb84f37e424655'
    Category = 'Windows Shortcuts'
    Tags = @('System', 'Boot', 'Windows PE')
    Silent = $true
    ToolTip = "Restart computer into ATOM's Windows PE environment"
    Description = 'Restart into the prepared ATOM Windows PE environment for offline maintenance. Access repair tools outside the installed operating system when Windows cannot start or a repair requires its files to be offline.'
    WorksInOs = $true
    WorksInPe = $false
    ShowIf = {
        $peKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\MiniNT')
        if ($peKey) { $peKey.Dispose(); return $false }
        [IO.File]::Exists((Join-Path $drivePath 'sources\boot.wim'))
    }
}

'Recuva'  = @{
    Id        = '9f0750e1ba6c443bbe6044a2ec40db9d'
    Category  = 'Data Services'
    Tags      = @('Recovery', 'Files', 'Storage')
    Silent    = $true
    ToolTip   = "File recovery software"
    Description = 'Search for deleted files on local drives and removable media, then recover available results to another location. Preview supported files and assess recovery prospects before choosing what to restore.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\Recuva"
        RelativePath    = 'recuva64.exe'
        Scoop           = 'extras/recuva'
        Uri             = 'https://download.ccleaner.com/rcsetup154.exe'
        ScriptBlock     = {
            Copy-ProgramItem @downloadParams | Expand-With7z -DestinationPath $destinationPath -Cleanup
        }
    }
}

'Registry Editor' = @{
    Id        = 'cc723b409d7d4744afe47a0f0dca04bd'
    Category  = 'Windows Shortcuts'
    Tags      = @('Registry', 'System', 'Settings')
    Silent    = $true
    ToolTip   = "View & modify registry keys & values"
    Description = 'Browse, search, and modify Windows registry keys and values. Import or export registry data when applying configuration changes, documenting settings, or troubleshooting software and system behavior.'
    WorksInOs = $true
    WorksInPe = $true
}

'RegRestore' = @{
    Id        = 'd6ed063eaeed4cc596b81620c811cdbe'
    Category  = 'Data Services'
    Tags      = @('Repair', 'Recovery', 'Registry')
    Silent    = $true
    ToolTip   = "Mini system restore to repair corrupted OS"
    Description = 'Restore an offline Windows installation''s registry hives from an available shadow copy. Select an earlier restore point to roll back registry damage while retaining backups of the current hives.'
    WorksInOs = $false
    WorksInPe = $true
}

'Regshot' = @{
    Id        = '904c6debf4bf4e4f850b58aaaa651ee5'
    Category  = 'Repair & Tune'
    Tags      = @('Registry', 'Diagnostics', 'Comparison')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "Registry comparison tool"
    Description = 'Take before-and-after registry snapshots and compare their differences. Include selected directories in the comparison to examine changes made by software installation or configuration work.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\Regshot"
        RelativePath    = 'Regshot-x64-Unicode.exe'
        Uri             = 'https://downloads.sourceforge.net/project/regshot/regshot/1.9.0/Regshot-1.9.0.7z'
        UserAgent       = 'wget'
    }
}

'Reset Default Services' = @{
    Id        = 'a29aef5302824a92b79f5288516615a6'
    Category  = 'Repair & Tune'
    Tags      = @('Repair', 'Services', 'System')
    Silent    = $true
    ToolTip   = "Restore default services to default states"
    Description = 'Restore Windows service startup settings to their defined defaults. Use this to recover from service changes that have disabled functionality or caused unexpected system behavior.'
    WorksInOs = $true
    WorksInPe = $true
}

'Restart to BIOS' = @{
    Id        = '6e5697f13c37489b80ca52b52a5ed3c0'
    Category  = 'Windows Shortcuts'
    Tags      = @('System', 'Boot', 'Firmware')
    Aliases   = @('uefi')
    Silent    = $true
    ToolTip   = "Restart computer to UEFI/BIOS"
    Description = 'Restart directly into the UEFI firmware settings screen on supported systems. Access boot order, virtualization, security, and other hardware configuration options without timing a startup key press.'
    WorksInOs = $true
    WorksInPe = $false
}

'Restart to Recovery' = @{
    Id        = 'b2c764d9dfcf4e5fad4641465d93fba3'
    Category  = 'Windows Shortcuts'
    Tags      = @('Recovery', 'Boot', 'System')
    Silent    = $true
    ToolTip   = "Restart computer to Windows Recovery Environment"
    Description = 'Restart into the Windows Recovery Environment to access advanced repair and startup options. Choose tools such as Startup Repair, System Restore, or recovery Command Prompt from the recovery menus.'
    WorksInOs = $true
    WorksInPe = $false
}

'Revo Uninstaller' = @{
    Id        = '4b2100c6456b4eb7a507c8e0a73fc978'
    Category  = 'Repair & Tune'
    Tags      = @('Software', 'Uninstall', 'Cleanup')
    Silent    = $true
    ToolTip   = "Deep program uninstaller"
    Description = 'Uninstall desktop applications and scan for leftover files, folders, and registry entries. Review the remaining items after the standard uninstaller finishes to complete a more thorough cleanup.'
    WorksInOs = $true
    WorksInPe = $false
    ProgramInfo = @{
        DestinationPath = "$programsPath\Revo Uninstaller"
        RelativePath    = '\RevoUninstaller_Portable\RevoUPort.exe'
        Scoop           = 'extras/revouninstaller'
        Uri             = 'https://download.revouninstaller.com/download/RevoUninstaller_Portable.zip'
        ScriptBlock     = {
            Copy-ProgramItem @downloadParams | Expand-With7z -DestinationPath $destinationPath -Cleanup
        }
    }
}

'Rufus' = @{
    Id        = '5bcd371a8bdc44c9b1f2f18cc725b47e'
    Category  = 'Data Services'
    Tags      = @('USB', 'Bootable', 'Deployment')
    Silent    = $true
    ToolTip   = "Create bootable drives, wide file format support"
    Description = 'Write bootable USB media from supported installation and recovery images. Choose partition and filesystem options to match the target computer when preparing operating system installation drives.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\Rufus"
        RelativePath    = 'rufus.exe'
        Scoop           = 'extras/rufus'
        Uri             = 'https://github.com/pbatard/rufus/releases/download/v4.6/rufus-4.6.exe'
        ScriptBlock     = {
            $outfile = Copy-ProgramItem @downloadParams -OutFile (Join-Path $atomTemp 'rufus.exe')
            if (!(Test-Path -LiteralPath $destinationPath)) { New-Item -Path $destinationPath -ItemType Directory -Force | Out-Null }
            Move-Item -LiteralPath $outfile.FullName -Destination (Join-Path $destinationPath 'rufus.exe') -Force
        }
    }
}

'Settings' = @{
    Id        = 'c9cf15a038874765a1188e25d83bf0da'
    Category  = 'Windows Shortcuts'
    Tags      = @('System', 'Settings', 'Windows')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "Windows setting app"
    Description = 'Open Windows Settings to configure accounts, devices, networking, updates, and other system features. Navigate the main settings categories when adjusting the computer''s everyday behavior.'
    WorksInOs = $true
    WorksInPe = $false
}

'Snappy Driver Installer Origin' = @{
    Id        = 'ba5ebb7feed348ffb89f40c5c2b273c2'
    Category  = 'Repair & Tune'
    Tags      = @('Drivers', 'Hardware', 'Updates')
    Aliases   = @('SDIO')
    Silent    = $true
    ToolTip   = "Robust driver updating software"
    Description = 'Identify missing or outdated drivers and choose matching packages for installation. Use downloaded driver packs for offline servicing when the target computer has limited or no network access.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\Snappy Driver Installer Origin"
        RelativePath    = 'SDIO_x64.exe'
        Scoop           = 'extras/snappy-driver-installer-origin'
        Uri             = 'https://www.glenn.delahoy.com/downloads/sdio/SDIO_1.13.5.772.zip'
        ScriptBlock     = {
            Get-ChildItem -LiteralPath $destinationPath -Filter 'SDIO_x64_R*.exe' -ErrorAction SilentlyContinue | Remove-Item -Force
            ($outfile = Copy-ProgramItem @downloadParams) | Expand-Archive -DestinationPath $destinationPath -Force
            $detectedExe = Get-ChildItem -LiteralPath $destinationPath -Filter 'SDIO_x64_R*.exe' | Select-Object -First 1
            if (!$detectedExe) { throw 'The SDIO x64 executable was not found in the downloaded archive.' }

            Move-Item -LiteralPath $detectedExe.FullName -Destination (Join-Path $destinationPath 'SDIO_x64.exe') -Force
            Remove-Item -LiteralPath $outfile.FullName -Force
        }
    }
}

'Speccy' = @{
    Id        = '99723403ae63438b9db47e8d17bce4ed'
    Category  = 'Diagnostics'
    Tags      = @('Hardware', 'Diagnostics', 'Monitoring')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "View detailed system hardware information"
    Description = 'View a summary of the operating system and installed components, with more detailed hardware breakdowns. Check specifications and available temperature readings when documenting a computer or planning upgrades.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\Speccy"
        RelativePath    = 'Speccy.exe'
        Scoop           = 'extras/speccy'
        Uri             = 'https://download.ccleaner.com/spsetup134.exe'
        ScriptBlock     = {
            $extractPath = "${destinationPath}.extract"
            if (Test-Path -LiteralPath $extractPath) { Remove-Item -LiteralPath $extractPath -Recurse -Force }

            Copy-ProgramItem @downloadParams | Expand-With7z -DestinationPath $extractPath -Cleanup
            $executable = Get-ChildItem -LiteralPath $extractPath -Filter 'Speccy64.exe' -Recurse | Select-Object -First 1
            if (!$executable) { throw 'The Speccy x64 executable was not found in the downloaded package.' }

            if (!(Test-Path -LiteralPath $destinationPath)) { New-Item -Path $destinationPath -ItemType Directory -Force | Out-Null }
            Move-Item -LiteralPath $executable.FullName -Destination (Join-Path $destinationPath $relativePath) -Force
            Set-Content -LiteralPath (Join-Path $destinationPath 'portable.dat') -Value '#PORTABLE#' -Encoding ASCII
            Remove-Item -LiteralPath $extractPath -Recurse -Force
        }
    }
}

'Task Manager' = @{
    Id        = '9e71e6dc142e439bb2f61179ca9512cb'
    Category  = 'Windows Shortcuts'
    Tags      = @('System', 'Processes', 'Monitoring')
    Silent    = $true
    ToolTip   = "View & manage all active process"
    Description = 'Inspect running applications, background processes, and live system resource usage. End unresponsive tasks, review startup applications, and investigate which processes are consuming CPU, memory, or disk activity.'
    WorksInOs = $true
    WorksInPe = $true
}

'Task Scheduler' = @{
    Id        = 'c79696c23d64499684903186bcf6971f'
    Category  = 'Windows Shortcuts'
    Tags      = @('System', 'Automation', 'Tasks')
    Silent    = $true
    ToolTip   = "Windows task automation system"
    Description = 'Inspect and manage tasks configured to run at specific times or in response to system events. Review triggers, actions, and execution history when troubleshooting automation or background activity.'
    WorksInOs = $true
    WorksInPe = $false
}

'Temp Cleanup' = @{
    Id        = '42e7403a4de14d999dca524a28001dde'
    Category = 'Repair & Tune'
    ArgumentList = '-Interactive'
    Tags = @('Cleanup', 'Temporary files')
    Silent = $true
    ToolTip = 'Clean old user and Windows temporary files'
    Description = 'Remove aged temporary files and clear Windows Internet cache, or select additional Windows cleanup categories through script parameters. Supports temp and Internet cache cleanup for the Windows installation selected with MountOS in PE. Reports cleanup results without emptying the Recycle Bin by default.'
    WorksInOs = $true
    WorksInPe = $true
}

'TeraCopy' = @{
    Id        = 'df0c75409f5349f6b375b8250dee8946'
    Category  = 'Data Services'
    Tags      = @('Files', 'Transfer', 'Utilities')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "Robust file transfer software"
    Description = 'Copy or move files with transfer queueing, pause and resume controls, and error handling. Verify transferred data to check file integrity when moving large collections or important backups.'
    WorksInOs = $true
    WorksInPe = $false
    # PE experiment: TeraCopy 4 initialized its portable data but showed no window. Try the older 3.17 build if revisited.
    # PeArgumentList = '/NoClose'
    ProgramInfo = @{
        DestinationPath = "$programsPath\TeraCopy"
        RelativePath    = 'TeraCopy\TeraCopy.exe'
        Uri             = 'https://codesector.com/files/teracopy.zip'
        ScriptBlock     = {
            $archive = Copy-ProgramItem @downloadParams
            if (!(Test-Path -LiteralPath $destinationPath)) {
                New-Item -Path $destinationPath -ItemType Directory -Force | Out-Null
            }
            Expand-Archive -LiteralPath $archive.FullName -DestinationPath $destinationPath -Force
            Remove-Item -LiteralPath $archive.FullName -Force
        }
    }
}

'Total Commander' = @{
    Id        = '3828c1022c3145d8b2afab041ff6a499'
    Category  = 'Data Services'
    Tags      = @('Files', 'File Manager', 'Utilities')
    Silent    = $true
    ToolTip   = "Alternative file explorer"
    Description = 'Manage files with two folder panes, tabs, archive support, and extensive file operations. Search, compare, or rename groups of files while keeping source and destination locations accessible.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\Total Commander"
        RelativePath    = 'TOTALCMD64.EXE'
        Scoop           = 'extras/totalcommander'
        Uri             = 'https://totalcommander.ch/1103/tcmd1103x64.exe'
        ScriptBlock     = {
            (Copy-ProgramItem @downloadParams), (Join-Path $destinationPath "INSTALL.CAB") | Expand-With7z -DestinationPath $destinationPath -Cleanup
        }
    }
}

'Trifecta' = @{
    Id        = '5d71d12dc67b49e1a032215c9ac55cd8'
    Category  = 'Repair & Tune'
    Tags      = @('Repair', 'Updates', 'System')
    Silent    = $true
    ToolTip   = "Run SFC, Windows Update, & MS Store updates"
    Description = 'Start System File Checker and request Windows and Microsoft Store update scans. Open the corresponding update interfaces so you can follow repair progress and handle available updates.'
    WorksInOs = $true
    WorksInPe = $false
}

'Uninstalr' = @{
    Id        = '5c6e54488686446693994cb180ac24b9'
    Category  = 'Repair & Tune'
    Tags      = @('Software', 'Uninstall', 'Cleanup')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "Remove programs and their leftover files"
    Description = 'Analyze installed software and remove selected applications along with associated leftovers. Review detected files and registry entries when cleaning up programs that leave data behind after uninstallation.'
    WorksInOs = $true
    WorksInPe = $false
    ProgramInfo = @{
        DestinationPath = "$programsPath\Uninstalr"
        RelativePath    = 'Uninstalr.exe'
        Scoop           = 'extras/uninstalr'
        Uri             = 'https://uninstalr.com/Uninstalr_Portable.exe'
    }
}

'Ventoy' = @{
    Id        = '20ec05c4b1c04b26886ed465342faa66'
    Category  = 'Data Services'
    Tags      = @('USB', 'Bootable', 'Deployment')
    Silent    = $true
    ToolTip   = "Bootable USB drive creator"
    Description = 'Prepare a USB drive that can boot multiple ISO and other supported image files. Add or replace images by copying files to the drive, then choose an image from the boot menu.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\Ventoy"
        RelativePath    = 'ventoy-*\Ventoy2Disk_X64.exe'
        Scoop           = 'extras/ventoy'
        Uri             = 'https://github.com/ventoy/Ventoy/releases/download/v1.1.17/ventoy-1.1.17-windows.zip'
        ScriptBlock     = {
            $archive = Copy-ProgramItem @downloadParams
            if (!(Test-Path -LiteralPath $destinationPath)) {
                New-Item -Path $destinationPath -ItemType Directory -Force | Out-Null
            }
            Expand-Archive -LiteralPath $archive.FullName -DestinationPath $destinationPath -Force
            Remove-Item -LiteralPath $archive.FullName -Force

            $alternateExe = Get-ChildItem -LiteralPath $destinationPath -Filter 'Ventoy2Disk_X64.exe' -File -Recurse |
                Where-Object { $_.Directory.Name -eq 'altexe' } |
                Select-Object -First 1
            if (!$alternateExe) {
                throw 'The x64 Ventoy2Disk executable was not found in the downloaded package.'
            }

            Copy-Item -LiteralPath $alternateExe.FullName -Destination (Join-Path $alternateExe.Directory.Parent.FullName 'Ventoy2Disk_X64.exe') -Force
        }
    }
}

'VLC' = @{
    Id        = '560e7964fbb148dc878ab755be1712bf'
    Category  = 'Misc'
    Tags      = @('Media', 'Audio', 'Video')
    Silent    = $true
    ToolTip   = "Play video, audio, discs, and network streams"
    Description = 'Play audio, video, discs, and network streams across a wide range of formats. Test media playback, inspect files, or open a stream without needing a separate player for each format.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\VLC"
        RelativePath    = 'vlc.exe'
        Scoop           = 'extras/vlc'
        Uri             = 'https://download.videolan.org/pub/vlc/3.0.23/win64/vlc-3.0.23-win64.7z'
        ScriptBlock     = {
            $extractPath = "${destinationPath}.extract"
            if (Test-Path -LiteralPath $extractPath) { Remove-Item -LiteralPath $extractPath -Recurse -Force }

            Copy-ProgramItem @downloadParams | Expand-With7z -DestinationPath $extractPath -UseConsole -Cleanup
            $executable = Get-ChildItem -LiteralPath $extractPath -Filter $relativePath -Recurse | Select-Object -First 1
            if (!$executable) { throw "Unable to locate '$relativePath' in the downloaded VLC archive." }

            if (!(Test-Path -LiteralPath $destinationPath)) {
                New-Item -Path $destinationPath -ItemType Directory -Force | Out-Null
            }
            Get-ChildItem -LiteralPath $executable.DirectoryName -Force | Copy-Item -Destination $destinationPath -Recurse -Force
            if (!(Test-Path -LiteralPath "$destinationPath\portable")) {
                New-Item -Path "$destinationPath\portable" -ItemType Directory -Force | Out-Null
            }
            Remove-Item -LiteralPath $extractPath -Recurse -Force
        }
    }
}

'Webroot' = @{
    Id        = 'd106bafb976445ec88825352b3d33e85'
    Category  = 'AV Scanners'
    Tags      = @('Security', 'Antivirus', 'Scanner')
    Silent    = $true
    ToolTip   = "Web-based AV scanner"
    Description = 'Run an on-demand antivirus scan to check the computer for malicious software. Review the scanner''s results when investigating suspicious behavior or seeking an additional assessment of system security.'
    # Disabled until a portable scan mode is verified.
    WorksInOs = $false
    WorksInPe = $false
    ProgramInfo = @{
        DestinationPath = "$programsPath\Webroot"
        RelativePath    = 'wsainstall.exe'
        Uri             = 'https://anywhere.webrootcloudav.com/zerol/wsainstall.exe'
    }
}

'Windows PE Build Kit' = @{
    Id        = '4c47b0f8556847828584a53a74b1aee1'
    Category  = 'ATOM Dependencies'
    Tags      = @('Windows PE', 'WinPE', 'ADK', 'Build Tools')
    Aliases   = @('PE Build Kit', 'ADK')
    DownloadOnly = $true
    Silent    = $true
    ToolTip   = 'Download the reusable Microsoft components needed to build ATOM Windows PE'
    Description = 'Download and cache the reusable Microsoft components required to build the ATOM Windows PE image. Reuse the prepared kit for later builds instead of downloading the same build dependencies again.'
    WorksInOs = $true
    WorksInPe = $false
    ProgramInfo = @{
        DestinationPath = "$programsPath\Windows PE Build Kit"
        RelativePath    = 'build-kit.json'
        VersionScriptBlock = {
            & "$pluginsPath\Windows PE ISO.ps1" -ResolveVersionOnly -PrepareBuildKit
        }
        ScriptBlock     = {
            & "$pluginsPath\Windows PE ISO.ps1" -DestinationPath $destinationPath -AtomRoot (Split-Path $atomPath) -ProgressState $ProgressState -PrepareBuildKit
        }
    }
}

'Windows PE ISO' = @{
    Id        = '88f9fda19724471683d5cfae8b137c4a'
    Category  = 'ATOM Dependencies'
    Tags      = @('Windows PE', 'WinPE', 'Boot', 'USB', 'Deployment', 'ADK')
    Aliases   = @('PE', 'Boot Media')
    DownloadOnly = $true
    Silent    = $true
    ToolTip   = 'Download and build the current Microsoft Windows PE ISO for ATOM'
    Description = 'Build the ATOM Windows PE ISO using Microsoft components and the prepared build kit. Create bootable repair media for accessing diagnostics and maintenance tools outside the installed Windows environment.'
    WorksInOs = $true
    WorksInPe = $true
    Dependencies = @('PowerShell Core', 'Windows PE Build Kit')
    ProgramInfo = @{
        DestinationPath = "$programsPath\Windows PE"
        RelativePath    = 'ATOM-PE.iso'
        VersionScriptBlock = {
            & "$pluginsPath\Windows PE ISO.ps1" -ResolveVersionOnly
        }
        ScriptBlock     = {
            & "$pluginsPath\Windows PE ISO.ps1" -DestinationPath $destinationPath -AtomRoot (Split-Path $atomPath) -BuildKitPath "$programsPath\Windows PE Build Kit" -ProgressState $ProgressState
        }
    }
}

'Debloat & Tune' = @{
    Id        = '7aa164daac104b5187398af4a439ce4d'
    Category  = 'Repair & Tune'
    Tags      = @('Privacy', 'Cleanup', 'Security')
    Silent    = $true
    ToolTip   = "Customize Windows, disable telemetry & remove unwanted apps"
    Description = 'Choose application removals, privacy adjustments, and Windows configuration changes from a categorized interface. Review and run selected actions to tailor an installation to its intended use.'
    WorksInOs = $true
    WorksInPe = $false
}

'WinGet Client Module' = @{
    Id        = 'c36c838d77284b37b231c84e38612ae2'
    Icon      = 'WinGet'
    Category  = 'ATOM Dependencies'
    Tags      = @('WinGet', 'PowerShell', 'Package Manager')
    Aliases   = @('Microsoft.WinGet.Client')
    DownloadOnly = $true
    Silent    = $true
    ToolTip   = 'Download the Microsoft WinGet PowerShell module'
    Description = 'Cache the Microsoft.WinGet.Client module for WinGet installation, repair, and application management. Downloads the module locally without installing it into Windows PowerShell.'
    WorksInOs = $true
    WorksInPe = $false
    ProgramInfo = @{
        DestinationPath = "$programsPath\Microsoft.WinGet.Client"
        RelativePath    = 'Microsoft.WinGet.Client.psd1'
        Uri             = 'https://www.powershellgallery.com/api/v2/package/Microsoft.WinGet.Client'
        UserAgent       = 'PowerShellGet/2.2.5'
        VersionScriptBlock = {
            $feedUri = 'https://www.powershellgallery.com/api/v2/Packages?$filter=Id%20eq%20%27Microsoft.WinGet.Client%27%20and%20IsLatestVersion%20eq%20true%20and%20IsPrerelease%20eq%20false'
            [xml]$feed = (Invoke-WebRequest -Uri $feedUri -UseBasicParsing -TimeoutSec 20 -ErrorAction Stop).Content
            $versions = @($feed.SelectNodes('//*[local-name()="properties"]/*[local-name()="Version"]'))
            if ($versions.Count -ne 1) { throw 'Unable to resolve the latest stable WinGet client module version.' }
            ([version]$versions[0].InnerText).ToString()
        }
        ScriptBlock     = {
            $moduleVersion = & $versionScriptBlock
            $downloadParams.Uri = "https://www.powershellgallery.com/api/v2/package/Microsoft.WinGet.Client/$moduleVersion"
            $archivePath = Join-Path ([IO.Path]::GetTempPath()) ('Microsoft.WinGet.Client-' + [Guid]::NewGuid().ToString('N') + '.zip')
            try {
                $outfile = Copy-ProgramItem @downloadParams -OutFile $archivePath
                Expand-Archive -LiteralPath $outfile -DestinationPath $destinationPath -Force
                if ($ProgressState) { $ProgressState.Version = $moduleVersion }
            } finally {
                if (Test-Path -LiteralPath $archivePath) { Remove-Item -LiteralPath $archivePath -Force }
            }
        }
    }
}

'WinMerge' = @{
    Id        = 'af2052dca8fb42aabbf0773649902e75'
    Category  = 'Data Services'
    Tags      = @('Files', 'Comparison', 'Development')
    Hidden    = $true
    Silent    = $true
    ToolTip   = "File comparison software"
    Description = 'Compare files and folders side by side, highlighting differences in their contents. Merge selected changes or check directory trees when reviewing edits, configuration files, or copied data.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\WinMerge"
        RelativePath    = 'WinMerge\WinMergeU.exe'
        Scoop           = 'extras/winmerge'
        Uri             = 'https://downloads.sourceforge.net/winmerge/winmerge-2.16.44-x64-exe.zip'
        UserAgent       = 'wget'
    }
}

'WinUtil' = @{
    Id        = 'd4877330180e45b3bcf4753f2a9eedc9'
    Hidden    = $true
    Category  = 'Repair & Tune'
    Tags      = @('System', 'Tweaks', 'Utilities')
    Aliases   = @('ctt')
    ToolTip   = "Windows tweaks utility by CTT & community"
    Description = 'Launch Chris Titus Tech''s Windows Utility for application installation, system tweaks, and configuration tasks. Choose the adjustments you need from the utility''s interface when setting up or maintaining Windows.'
    WorksInOs = $true
    WorksInPe = $false
}

'WizTree' = @{
    Id        = '47c57fe6ebc34824ac20f4b2cf79002f'
    Category  = 'Data Services'
    Tags      = @('Storage', 'Disk', 'Analysis')
    Silent    = $true
    ToolTip   = "Examine sizes of all local directories"
    Description = 'Scan drive usage and display which files and folders occupy the most space. Explore a visual treemap or sorted file lists to locate large items and investigate unexpectedly full storage.'
    WorksInOs = $true
    WorksInPe = $true
    ProgramInfo = @{
        DestinationPath = "$programsPath\WizTree"
        RelativePath    = 'WizTree64.exe'
        Scoop           = 'extras/wiztree'
        Uri             = 'https://diskanalyzer.com/files/wiztree_4_23_portable.zip'
    }
}


}

# Capture the built-in values used to decide whether a user override is still necessary.
$programDefaults = [ordered]@{}
$programNameById = @{}
foreach ($program in $programs.Keys) {
    $pluginId = [String]$programs[$program].Id
    if ($pluginId -notmatch '^[a-f0-9]{32}$' -or $programNameById.ContainsKey($pluginId)) { throw "Invalid or duplicate plugin ID for '$program'." }
    $programNameById[$pluginId] = $program
    $programDefaults[$program] = [ordered]@{
        Id = $pluginId
        Category = if ($programs[$program].Contains('Category')) { [String]$programs[$program].Category } else { $null }
        Hidden   = if ($programs[$program].Contains('Hidden')) { [Boolean]$programs[$program].Hidden } else { $false }
        Favorite = if ($programs[$program].Contains('Favorite')) { [Boolean]$programs[$program].Favorite } else { $false }
    }
}
# Load user-defined plugins and overrides from one canonical hashtable.
if (Test-Path "$psScriptRoot\PluginsUser.ps1") {
    # Keep the nested import from replacing an outer import's feature options.
    $userPrograms = & {
        param($LibraryPath, $OverridesPath)
        . $LibraryPath -Function Read-AtomPluginOverrides
        Read-AtomPluginOverrides -Path $OverridesPath
    } "$PSScriptRoot/../Functions/Import-Atom.ps1" "$PSScriptRoot/PluginsUser.ps1"

    foreach ($entry in $userPrograms.GetEnumerator()) {
        $metadata = $entry.Value
        $program = $programNameById[$entry.Key]
        if ($metadata.UserOwned) {
            if ($program -or $programDefaults.Contains($metadata.Name)) { throw "User plugin '$($metadata.Name)' conflicts with the built-in catalog." }
            $program = [String]$metadata.Name
        } elseif (!$program -and $metadata.Name -and !$programDefaults.Contains($metadata.Name)) {
            $program = [String]$metadata.Name
        }
        # Preferences for removed plugins remain on disk but do not follow reused names.
        if (!$program) { continue }
        if ($programs.Keys -notcontains $program) {
            $programs[$program] = [ordered]@{}
        }

        foreach ($property in $metadata.Keys) {
            if ($property -eq 'ProgramInfo') {
                if ($metadata.ProgramInfo -isnot [System.Collections.IDictionary]) {
                    throw "ProgramInfo for '$program' must be a hashtable."
                }
                if (!$programs[$program].ProgramInfo) {
                    $programs[$program].ProgramInfo = [ordered]@{}
                }

                foreach ($programProperty in $metadata.ProgramInfo.Keys) {
                    $programs[$program].ProgramInfo[$programProperty] = $metadata.ProgramInfo[$programProperty]
                }
            } else {
                $programs[$program][$property] = $metadata[$property]
            }
        }
    }
}
