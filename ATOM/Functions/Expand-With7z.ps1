function Expand-With7z {
    <#
    .SYNOPSIS
    Extracts files from an archive using the 7-Zip utility.

    .DESCRIPTION
    The `Expand-With7z` function extracts files from an archive using the 7-Zip utility, either by downloading and using the console version (`7zr.exe`) or the full executable version of 7-Zip.  It supports running a custom script block after extraction and performs cleanup of temporary files after execution.

    This function can work in two modes:
    - **Console Extraction**: Uses the lightweight `7zr.exe` for extraction.
    - **Full 7-Zip Extraction**: Downloads and extracts the full version of 7-Zip for more advanced capabilities.

    .PARAMETER UseConsole
    When specified, forces the function to use the console version of 7-Zip (`7zr.exe`) to extract the archive. Optional.

    .PARAMETER Cleanup
    When specified, removes the compressed file after decompression.

    .EXAMPLE
    Expand-With7z -Path "C:\Temp\example.zip" -DestinationPath "C:\Temp\uncompressed"
    Extracts the archive to "C:\Temp\uncompressed" using the full version of 7-Zip.

    .EXAMPLE
    Expand-With7z -Path "C:\Temp\example.zip" -UseConsole -Cleanup
    Extracts the archive to "C:\Temp\example" using the console version of 7-Zip, then removes the archive file.

    .EXAMPLE
    Copy-WebItem -Uri "https://example.com/file.zip" | Expand-With7z -DestinationPath "C:\Temp\"
    Downloads the file from the specified URL and then extracts the contents of the zip to "C:\Temp\file".

    .INPUTS
    None. This function does not accept any pipeline input.

    .OUTPUTS
    None. This function does not produce output to the pipeline.

    .NOTES
    Author: Skyler Wallace
    
    .LINK
    For more information on 7-Zip command line switches, visit:
    https://web.mit.edu/outland/arch/i386_rhel4/build/p7zip-current/DOCS/MANUAL/
    #>
    
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [String]$Path,

        [Parameter(Position = 1)]
        [String]$DestinationPath,

        [Switch]$UseConsole,

        [Switch]$Cleanup,

        [Switch]$NoClobber,

        [ScriptBlock]$ScriptBlock
    )
    
    begin {
        # Download 7-Zip console version
        $progressPreference = 'SilentlyContinue' # Supress progress bar to prioritize download speed
        $7zConsoleUrl = "https://www.7-zip.org/a/7zr.exe"
        $7zConsolePath = Join-Path $env:TEMP "7zr.exe"
        Invoke-WebRequest $7zConsoleUrl -OutFile $7zConsolePath

        # Early return if -UseConsole used
        if ($UseConsole) { return }
        
        # Download 7-Zip exe version
        $7zInstallerUrl = (Invoke-RestMethod -Uri https://api.github.com/repos/ip7z/7zip/releases/latest -Method Get -UseBasicParsing).assets.browser_download_url | Where-Object { $_.EndsWith('-x64.exe') }
        $7zInstallerPath = Join-Path $env:TEMP "7-Zip.exe"
        Invoke-WebRequest $7zInstallerUrl -OutFile $7zInstallerPath
        
        # Use 7z console to extract 7z exe version
        $7zPortablePath = Join-Path $env:TEMP "7-Zip"
        $7zConsoleProcess = Start-Process $7zConsolePath -ArgumentList "x `"$7zInstallerPath`" -o`"$7zPortablePath`" -y" -Wait -PassThru
        if ($7zConsoleProcess.ExitCode -eq 0) {
            Write-Verbose "Portable 7-Zip extracted from 7-Zip installer."
        } else {
            Write-Error "Failed to extract portable 7-Zip, exit code $($7zConsoleProcess.ExitCode)."
            return
        }

        $7zExe = Join-Path $7zPortablePath "7z.exe"
    }

    process {
        # Treat destinationPath
        if (!$DestinationPath) {
            $DestinationPath = Join-Path (Split-Path $Path) ([System.IO.Path]::GetFileNameWithoutExtension($Path))
        } elseif ($DestinationPath.EndsWith('\')) {
            $DestinationPath = Join-Path $DestinationPath ([System.IO.Path]::GetFileNameWithoutExtension($Path))
        }

        # Attempt extraction
        $7zExeProcess = if ($UseConsole) {
            Write-Verbose "Extracting '$Path' with '$7zConsolePath'."
            Start-Process $7zConsolePath -ArgumentList "x `"$Path`" -o`"$DestinationPath`" -y" -Wait -PassThru
        } else {
            Write-Verbose "Extracting '$Path' with '$7zExe'."
            Start-Process $7zExe -ArgumentList "x `"$Path`" -o`"$DestinationPath`" -y" -Wait -PassThru
        }

        # Output
        if ($7zExeProcess.ExitCode -eq 0) {
            Write-Verbose "Extracted '$Path' to '$DestinationPath'."
        } else {
            Write-Error "Failed to extract '$Path' to '$DestinationPath'.`nExit Code : $($7zExeProcess.ExitCode)"
            return
        }

        # Run scriptblock if -ScriptBlock parameter is defined
        if ($ScriptBlock) { Invoke-Command -ScriptBlock $ScriptBlock -NoNewScope }

        # Remove file
        if ($Cleanup) {
            Write-Verbose "Removing '$Path'."
            Remove-Item -LiteralPath $Path -Force -Recurse
        }

        # Return [System.IO.FileInfo] object
        Get-Item $DestinationPath
    }
    
    end {
        # Cleanup
        $7zConsolePath, $7zInstallerPath, $7zPortablePath | ForEach-Object {
            if ($_ -ne $null) { Remove-Item $_ -Recurse -Force }
        }
    }
}