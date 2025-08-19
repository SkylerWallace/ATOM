function Expand-With7z {
    <#
    .SYNOPSIS
    Extracts files from an archive using the 7-Zip utility.

    .DESCRIPTION
    The `Expand-With7z` function extracts files from an archive using the 7-Zip utility, either by downloading and using the console version (`7zr.exe`) or the full executable version of 7-Zip. 
    It supports running a custom script block after extraction and performs cleanup of temporary files after execution.

    This function can work in two modes:
    - **Console Extraction**: Uses the lightweight `7zr.exe` for extraction.
    - **Full 7-Zip Extraction**: Downloads and extracts the full version of 7-Zip for more advanced capabilities.

    .PARAMETER ConsoleExtract
    When specified, forces the function to use the console version of 7-Zip (`7zr.exe`) to extract the archive. Optional.

    .PARAMETER Cleanup
    When specified, removes the compressed file after decompression.

    .EXAMPLE
    Expand-With7z -Path "C:\Temp\example.zip" -DestinationPath "C:\Temp\uncompressed"
    Extracts the archive to "C:\Temp\uncompressed" using the full version of 7-Zip.

    .EXAMPLE
    Expand-With7z -Path "C:\Temp\example.zip" -ConsoleExtract -Cleanup
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
        [string]$path,
        [Parameter(Position = 1)]
        [string]$destinationPath,
        [switch]$consoleExtract,
        [switch]$cleanup
    )
    
    begin {
        # Download 7-Zip console version
        $progressPreference = 'SilentlyContinue' # Supress progress bar to prioritize download speed
        $7zConsoleUrl = "https://www.7-zip.org/a/7zr.exe"
        $7zConsolePath = Join-Path $env:TEMP "7zr.exe"
        Invoke-WebRequest $7zConsoleUrl -OutFile $7zConsolePath

        # Early return if -ConsoleExtract used
        if ($consoleExtract) { return }
        
        # Download 7-Zip exe version
        $7zInstallerUrl = (Invoke-RestMethod -Uri https://api.github.com/repos/ip7z/7zip/releases/latest -Method Get -UseBasicParsing).assets.browser_download_url | Where-Object { $_.EndsWith('-x64.exe') }
        $7zInstallerPath = Join-Path $env:TEMP "7-Zip.exe"
        Invoke-WebRequest $7zInstallerUrl -OutFile $7zInstallerPath
        
        # Use 7z console to extract 7z exe version
        $7zPortablePath = Join-Path $env:TEMP "7-Zip"
        $7zConsoleProcess = Start-Process $7zConsolePath -ArgumentList "x `"$7zInstallerPath`" -o`"$7zPortablePath`" -y" -Wait -PassThru
        switch ($7zConsoleProcess.ExitCode) {
            0 { Write-Verbose "Portable 7-Zip extracted from 7-Zip installer." }
            default {
                Write-Error "Failed to extract portable 7-Zip, exit code $($7zConsoleProcess.ExitCode)."
                return
            }
        }
        
        $7zExe = Join-Path $7zPortablePath "7z.exe"
    }

    process {
        # Treat destinationPath
        $destinationPath = if (!$destinationPath) {
            Join-Path (Split-Path $path) ([System.IO.Path]::GetFileNameWithoutExtension($path))
        } elseif ($destinationPath.EndsWith('\')) {
            Join-Path $destinationPath ([System.IO.Path]::GetFileNameWithoutExtension($path))
        }

        # Attempt extraction
        $7zExeProcess = if ($consoleExtract) {
            Write-Verbose "Extracting '$path' with '$7zConsolePath'."
            Start-Process $7zConsolePath -ArgumentList "x `"$path`" -o`"$destinationPath`" -y" -Wait -PassThru
        } else {
            Write-Verbose "Extracting '$path' with '$7zExe'."
            Start-Process $7zExe -ArgumentList "x `"$path`" -o`"$destinationPath`" -y" -Wait -PassThru
        }

        # Output based on exit code
        switch ($7zExeProcess.ExitCode) {
            0 { Write-Verbose "Extracted '$path' to '$destinationPath'." }
            default {
                Write-Error "Failed to extract '$path' to '$destinationPath'.`nExit Code : $($7zExeProcess.ExitCode)"
                return
            }
        }

        # Return [System.IO.FileInfo] object
        Get-Item $destinationPath
    }
    
    end {
        # Cleanup
        $7zConsolePath, $7zInstallerPath, $7zPortablePath | ForEach-Object {
            if ($_ -ne $null) { Remove-Item $_ -Recurse -Force }
        }

        if ($cleanup) {
            switch ($7zExeProcess.ExitCode) {
                0 {
                    Write-Verbose "Removing '$path' since extraction was successful."
                    Remove-Item -LiteralPath $path -Force -Recurse
                }
            }
        }
    }
}