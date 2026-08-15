$programs = [ordered]@{

'7-Zip' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "File management, compression, & extraction"
        WorksInOs = $true
        WorksInPe = $true
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\7-Zip"
        RelativePath    = "7zFM.exe"
        Uri             = 'https://7-zip.org/a/7z2409-x64.exe'
        ScriptBlock     = {
            Copy-WebItem -Uri $programs.'7-Zip'.ProgramInfo.Uri -OutFile $env:TEMP\ -ProgressState $progressState | Expand-With7z -DestinationPath $destinationPath -UseConsole -Cleanup
        }
    }
}

'AnyBurn' = @{
    PluginInfo = @{
        Hidden    = $true
        Silent    = $true
        ToolTip   = "CD/DVD & ISO burning software"
        WorksInOs = $true
        WorksInPe = $true
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\AnyBurn"
        RelativePath    = '\AnyBurn(64-bit)\AnyBurn.exe'
        Scoop           = 'extras/anyburn'
        Uri             = 'https://www.anyburn.com/anyburn.zip'
    }
}

'ATOM Notes' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Take notes during PC repair"
        WorksInOs = $true
        WorksInPe = $false
    }
}

'ATOMizer' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Format/update multiple flash drives w/ zip & ISO files"
        WorksInOs = $true
        WorksInPe = $true
    }
}
    
'Autoruns'  = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "View/modify all computer startups"
        WorksInOs = $true
        WorksInPe = $true
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\Autoruns"
        RelativePath    = 'Autoruns64.exe'
        Scoop           = 'sysinternals/autoruns'
        Uri             = 'https://download.sysinternals.com/files/Autoruns.zip'
    }
}

'BlueScreenView' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "View blue screen crash dumps"
        WorksInOs = $true
        WorksInPe = $true
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\BlueScreenView"
        RelativePath    = 'BlueScreenView.exe'
        Scoop           = 'nirsoft/bluescreenview'
        Uri             ='https://www.nirsoft.net/utils/bluescreenview-x64.zip'
    }
}

'Command Prompt' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Windows legacy command-line"
        WorksInOs = $true
        WorksInPe = $true
    }
}

'Control Panel' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Windows legacy Control Panel"
        WorksInOs = $true
        WorksInPe = $false
    }
}

'CPU-Z' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "View CPU info, benchmarking, & stress testing"
        WorksInOs = $true
        WorksInPe = $true
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\CPU-Z"
        RelativePath    = 'cpuz_x64.exe'
        Scoop           = 'extras/cpu-z'
        Uri             = 'https://download.cpuid.com/cpu-z/cpu-z_2.12-en.zip'
    }
}

'CrystalDiskInfo' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "View drive health & info"
        WorksInOs = $true
        WorksInPe = $true
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\CrystalDiskInfo"
        RelativePath    = 'DiskInfo64.exe'
        Scoop           = 'extras/crystaldiskinfo'
        Uri             = 'https://crystalmark.info/download/zz/CrystalDiskInfo9_4_3.zip'
    }
}

'CrystalDiskMark' = @{
    PluginInfo = @{
        Hidden    = $true
        Silent    = $true
        ToolTip   = "Test drive read/write speeds"
        WorksInOs = $true
        WorksInPe = $true
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\CrystalDiskMark"
        RelativePath    = 'DiskMark64.exe'
        Scoop           = 'extras/crystaldiskmark'
        Uri             = 'https://crystalmark.info/download/zz/CrystalDiskMark8_0_4c.zip'
    }
}

'Detectron' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Disable telemetry & uninstall bloatware/malware"
        WorksInOs = $true
        WorksInPe = $false
    }
}

'Device Manager' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "View & manage device info & drivers"
        WorksInOs = $true
        WorksInPe = $false
    }
}

'Disk Management' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Manage local drives"
        WorksInOs = $true
        WorksInPe = $true
    }
}

'Display Driver Uninstaller' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Completely remove GPU drivers"
        WorksInOs = $true
        WorksInPe = $false
    }
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

'Event Viewer' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "View Windows event logs"
        WorksInOs = $true
        WorksInPe = $false
    }
}

'Explorer++' = @{
    PluginInfo = @{
        Hidden    = $true
        Silent    = $true
        ToolTip   = "Alternative file explorer"
        WorksInOs = $true
        WorksInPe = $true
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\Explorer++"
        RelativePath    = 'Explorer++.exe'
        Scoop           = 'extras/explorerplusplus'
        Uri             = 'https://download.explorerplusplus.com/stable/1.4.0/explorerpp_x64.zip'
    }
}

'FreeCommander' = @{
    PluginInfo = @{
        Hidden    = $true
        Silent    = $true
        ToolTip   = "Alternative file explorer"
        WorksInOs = $true
        WorksInPe = $false
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\FreeCommander"
        RelativePath    = 'FreeCommander.exe'
        Scoop           = 'extras/freecommander'
        Uri             = 'https://freecommander.com/downloads/FreeCommanderXE-32-public_portable.zip'
    }
}

'HCI Design MemTest' = @{
    PluginInfo = @{
        Hidden    = $true
        Silent    = $true
        ToolTip   = "Alternative file explorer"
        WorksInOs = $true
        WorksInPe = $false
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\HCI Design MemTest"
        RelativePath    = 'memtest.exe'
        Uri             = 'https://hcidesign.com/memtest/MemTest.zip'
    }
}

'HWMonitor' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Real-time hardware monitoring"
        WorksInOs = $true
        WorksInPe = $true
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\HWMonitor"
        RelativePath    = 'HWMonitor_x64.exe'
        Scoop           = 'extras/hwmonitor'
        Uri             = 'https://download.cpuid.com/hwmonitor/hwmonitor_1.55.zip'
    }
}

'Installed Apps' = @{
    PluginInfo = @{
        Hidden    = $true
        Silent    = $true
        ToolTip   = "Windows Settings app management"
        WorksInOs = $true
        WorksInPe = $false
    }
}

'KeyCutlass' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "View Windows product & encryption keys"
        WorksInOs = $true
        WorksInPe = $true
    }
}

'MalwareBytes AdwCleaner' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "MBAM malware scanner"
        WorksInOs = $true
        WorksInPe = $false
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\MalwareBytes AdwCleaner"
        RelativePath    = 'adwcleaner.exe'
        Scoop           = 'extras/adwcleaner'
        Uri             = 'https://adwcleaner.malwarebytes.com/adwcleaner?channel=release'
    }
}

'McAfee Stinger' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "McAfee AV scanner"
        WorksInOs = $true
        WorksInPe = $false
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\McAfee Stinger"
        RelativePath    = 'stinger64.exe'
        Uri             = 'https://downloadcenter.trellix.com/products/mcafee-avert/Stinger/stinger64.exe'
    }
}

'MemTest86' = @{
    PluginInfo = @{
        Hidden    = $true
        Silent    = $true
        ToolTip   = "Bootable memory tester"
        WorksInOs = $true
        WorksInPe = $false
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\MemTest86"
        RelativePath    = 'imageUSB.exe'
        Uri             = 'https://www.memtest86.com/downloads/memtest86-usb.zip'
    }
}

'MountOS' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Mount offline registry hives for OS modification"
        WorksInOs = $false
        WorksInPe = $true
    }
}

'MSI Kombustor' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "GPU stress-tester"
        WorksInOs = $true
        WorksInPe = $false
    }
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

'Neutron' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "New PC suite: install programs & set common settings"
        WorksInOs = $true
        WorksInPe = $false
    }
}

'Norton Power Eraser' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Norton AV scanner"
        WorksInOs = $true
        WorksInPe = $false
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\Norton Power Eraser"
        RelativePath    = 'NPE.exe'
        Uri             = 'https://www.norton.com/npe_latest'
    }
}

'Notepad++' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Notepad but with two pluses"
        WorksInOs = $true
        WorksInPe = $true
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\Notepad++"
        RelativePath    = 'notepad++.exe'
        Scoop           = 'extras/notepadplusplus'
        Uri             = 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.7.4/npp.8.7.4.portable.x64.zip'
    }
}

'O&O Shutup10++' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Thorough telemetry disabler"
        WorksInOs = $true
        WorksInPe = $false
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\O&O Shutup10++"
        RelativePath    = 'OOSU10.exe'
        Scoop           = 'extras/shutup10'
        Uri             = 'https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe'
    }
}

'OCCT' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "All-in-one diagnostic, stability, & stress-tester"
        WorksInOs = $true
        WorksInPe = $false
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\OCCT"
        RelativePath    = 'OCCT.exe'
        Uri             = 'https://www.ocbase.com/download/edition:Personal'
    }
}

'OneCommander' = @{
    PluginInfo = @{
        Hidden    = $true
        Silent    = $true
        ToolTip   = "Alternative file explorer"
        WorksInOs = $true
        WorksInPe = $false
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\OneCommander"
        RelativePath    = 'OneCommander.exe'
        Scoop           = 'extras/onecommander'
        Uri             = 'https://onecommander.com/OneCommander3.93.0.0.zip'
    }
}

'Orca' = @{
    PluginInfo = @{
        Hidden    = $true
        Silent    = $true
        ToolTip   = "Official Microsoft tool to analyze and modify MSIs"
        WorksInOs = $true
        WorksInPe = $false
    }
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
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Disable Windows S-Mode"
        WorksInOs = $true
        WorksInPe = $false
    }
}

'Opera' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Portable web browser"
        WorksInOs = $true
        WorksInPe = $true
    }
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

'PassCrack' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Disable Windows login passwords (requires MountOS ran)"
        WorksInOs = $false
        WorksInPe = $true
    }
}

'PowerShell' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Windows modern command-line (native)"
        WorksInOs = $true
        WorksInPe = $true
    }
}

'PowerShell Core' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Windows modern command-line (non-native)"
        WorksInOs = $true
        WorksInPe = $true
    }
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
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "CPU stability tester"
        WorksInOs = $true
        WorksInPe = $true
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\Prime95"
        RelativePath    = 'prime95.exe'
        Scoop           = 'extras/prime95'
        Uri             = 'https://download.mersenne.ca/gimps/v30/30.19/p95v3019b20.win64.zip'
    }
}

'Process Monitor' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Real-time process monitoring & snapshotting"
        WorksInOs = $true
        WorksInPe = $true
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\Process Monitor"
        RelativePath    = 'ProcMon64.exe'
        Scoop           = 'sysinternals/procmon'
        Uri             = 'https://download.sysinternals.com/files/ProcessMonitor.zip'
    }
}

'Recuva'  = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "File recovery software"
        WorksInOs = $true
        WorksInPe = $true
    }
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
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "View & modify registry keys & values"
        WorksInOs = $true
        WorksInPe = $true
    }
}

'RegRestore' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Mini system restore to repair corrupted OS"
        WorksInOs = $false
        WorksInPe = $true
    }
}

'Regshot' = @{
    PluginInfo = @{
        Hidden    = $true
        Silent    = $true
        ToolTip   = "Registry comparison tool"
        WorksInOs = $true
        WorksInPe = $true
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\Regshot"
        RelativePath    = 'Regshot-x64-Unicode.exe'
        Uri             = 'https://downloads.sourceforge.net/project/regshot/regshot/1.9.0/Regshot-1.9.0.7z'
        UserAgent       = 'wget'
    }
}

'Reset Default Services' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Restore default services to default states"
        WorksInOs = $true
        WorksInPe = $true
    }
}

'Restart to BIOS' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Restart computer to UEFI/BIOS"
        WorksInOs = $true
        WorksInPe = $false
    }
}

'Restart to Recovery' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Restart computer to Windows Recovery Environment"
        WorksInOs = $true
        WorksInPe = $false
    }
}

'Revo Uninstaller' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Deep program uninstaller"
        WorksInOs = $true
        WorksInPe = $false
    }
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
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Create bootable drives, wide file format support"
        WorksInOs = $true
        WorksInPe = $true
    }
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
    PluginInfo = @{
        Hidden    = $true
        Silent    = $true
        ToolTip   = "Windows setting app"
        WorksInOs = $true
        WorksInPe = $false
    }
}

'Snappy Driver Installer Origin' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Robust driver updating software"
        WorksInOs = $true
        WorksInPe = $false
    }
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

'Task Manager' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "View & manage all active process"
        WorksInOs = $true
        WorksInPe = $true
    }
}

'Task Scheduler' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Windows task automation system"
        WorksInOs = $true
        WorksInPe = $false
    }
}

'TeraCopy' = @{
    PluginInfo = @{
        Hidden    = $true
        Silent    = $true
        ToolTip   = "Robust file transfer software"
        WorksInOs = $true
        WorksInPe = $false
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\TeraCopy"
        RelativePath    = 'TeraCopy.exe'
        Scoop           = 'nonportable/teracopy-np'
        Uri             = 'https://www.codesector.com/files/teracopy.exe'
        ScriptBlock     = {
            if (!(Test-Path $destinationPath)) { New-Item -Path $destinationPath -ItemType Directory -Force | Out-Null }
            $outfile = Copy-ProgramItem @downloadParams
            Start-Process $outfile -ArgumentList "/extract `"$destinationPath`"" -Wait
            Remove-Item -LiteralPath $outfile.FullName -Force
            
            $subFolder = (Get-ChildItem -Path $destinationPath -Directory | Select-Object -First 1).FullName
            Get-ChildItem -Path $subFolder | Move-Item -Destination $destinationPath
            Remove-Item -Path $subFolder -Force
        }
    }
}

'Total Commander' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Alternative file explorer"
        WorksInOs = $true
        WorksInPe = $true
    }
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
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Run SFC, Windows Update, & MS Store updates"
        WorksInOs = $true
        WorksInPe = $false
    }
}

'Webroot' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Web-based AV scanner"
        WorksInOs = $true
        WorksInPe = $false
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\Webroot"
        RelativePath    = 'wsainstall.exe'
        Uri             = 'https://anywhere.webrootcloudav.com/zerol/wsainstall.exe'
        ArgumentList    = "-scandepth=quick"
    }
}

'WinMerge' = @{
    PluginInfo = @{
        Hidden    = $true
        Silent    = $true
        ToolTip   = "File comparison software"
        WorksInOs = $true
        WorksInPe = $true
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\WinMerge"
        RelativePath    = 'WinMerge\WinMergeU.exe'
        Scoop           = 'extras/winmerge'
        Uri             = 'https://downloads.sourceforge.net/winmerge/winmerge-2.16.44-x64-exe.zip'
        UserAgent       = 'wget'
    }
}

'WizTree' = @{
    PluginInfo = @{
        Silent    = $true
        ToolTip   = "Examine sizes of all local directories"
        WorksInOs = $true
        WorksInPe = $true
    }
    ProgramInfo = @{
        DestinationPath = "$programsPath\WizTree"
        RelativePath    = 'WizTree64.exe'
        Scoop           = 'extras/wiztree'
        Uri             = 'https://diskanalyzer.com/files/wiztree_4_23_portable.zip'
    }
}

}

# Load user programs
if (Test-Path "$psScriptRoot\PluginsUser.ps1") {
    . "$psScriptRoot\PluginsUser.ps1"
    foreach ($program in $userPlugins.Keys) {
        if ($programs.Keys -notcontains $program) {
            $programs.$program = $userPrograms.$program
            continue
        }

        foreach ($section in $userPrograms.$program.Keys) {
            foreach ($property in $userPrograms.$program.$section.Keys) {
                $programs.$program.$section.$property = $userPrograms.$program.$section.$property
            }
        }
    }    
}