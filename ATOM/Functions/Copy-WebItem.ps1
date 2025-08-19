function Copy-WebItem {
    <#
    .SYNOPSIS
    Downloads a file from a specified URL and displays a progress bar.

    .DESCRIPTION
    The `Copy-WebItem` function downloads a file from a specified URL to a target file path. It supports custom
    HTTP headers, progress reporting, and an option to prevent overwriting existing files.

    .PARAMETER Uri
    Specifies the URL to download the file. Alias: 'Url'.

    .PARAMETER OutFile
    Specifies the path where the downloaded file will be saved. If not specified, the file will be saved in the
    system's TEMP directory with a name derived from the URL. Optional.

    .PARAMETER Headers
    Specifies a hashtable of custom headers to include in the HTTP request. Useful for providing authentication tokens
    or other headers required by the server. Optional.

    .PARAMETER NoClobber
    Prevents overwriting an existing file if it already exists at the specified path. If the file exists and has the
    same length as the remote file, an error is generated instead of downloading again.

    .EXAMPLE
    Copy-WebItem -Uri "https://example.com/file.zip" -OutFile "C:\Users\Owner\Downloads\file.zip"
    Downloads the file from the specified URL and saves it to `C:\Users\Owner\Downloads\file.zip`.

    .EXAMPLE
    Copy-WebItem -Uri "https://example.com/file.zip" -NoClobber
    Attempts to download the file, but throws an error if the target file already exists with the same size.

    .EXAMPLE
    Copy-WebItem -Uri "https://example.com/file.zip" -Headers @{ Authorization = "Bearer token123" }
    Downloads the file from the specified URL, including a custom Authorization header in the HTTP request.

    .EXAMPLE
    "https://example.com/file1.zip","https://example.com/file2.zip" | Copy-WebItem -OutFile "C:\Temp\"
    Downloads multiple files from the pipeline and saves them to `C:\Temp\` using their original file names.

    .EXAMPLE
    Copy-WebItem -Uri "https://example.com/file.zip" | Expand-Archive
    Downloads the file from the specified URL and then extracts the contents of the zip.

    .OUTPUTS
    [System.IO.FileInfo]
    Returns a FileInfo object representing the downloaded file.
    
    .NOTES
    Author: Skyler Wallace
    Requires: Internet connection to download files.
    #>

    [CmdletBinding()]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [alias('Url')]
        [string]$uri,
        [Parameter(Position = 1)]
        [string]$outfile = $null,
        [hashtable]$headers = $null,
        [switch]$noClobber
    )
    
    process {
        # Get download info
        $response = Invoke-WebRequest -Uri $uri -Headers $headers -Method Head -UseBasicParsing
        $fileName = $response.Headers.'Content-Disposition'.Split('=',2)[-1]
        [int]$fileSizeBytes = $response.Headers.'Content-Length'
        $fileSizeMb = [math]::Round($fileSizeBytes / 1MB, 2)

        # Treat outfile path
        $name = if ($fileName) { $fileName } else { Split-Path $uri -Leaf }
        $outfile = if (!$outfile) {
            Join-Path (Get-Location) $name
        } elseif ($outfile.EndsWith('\')) {
            Join-Path $outfile $name
        }

        if ($noClobber -and (Test-Path $outfile) -and ($fileSizeBytes -eq (Get-Item $outfile).Length)) {
            $errRecord = [System.Management.Automation.ErrorRecord]::new(
                ([System.IO.IOException]::new("The file '$OutFile' already exists.")),
                'NoClobber',
                [System.Management.Automation.ErrorCategory]::ResourceExists,
                $OutFile
            )
            $errRecord.CategoryInfo.Activity = $MyInvocation.MyCommand.Name
            Write-Error $errRecord
            return
        } elseif ((Test-Path $outfile) -and ($fileSizeBytes -eq (Get-Item $outfile).Length)) {
            Write-Verbose "Overwriting '$outfile' with download."
        }

        # Download file as job
        Write-Verbose "Downloading from $uri"
        $downloadJob = Start-Job {
            param($uri, $headers, $outfile)
            Invoke-WebRequest -Uri $uri -Headers $headers -OutFile $outfile -UseBasicParsing
        } -ArgumentList $uri, $headers, $outfile
        
        # Output to progress bar as job runs
        while ($downloadJob.State -eq 'Running') {
            if (!(Test-Path $outfile)) { continue }
            if (!$fileSizeBytes) {
                Write-Progress (Split-Path $outfile -Leaf) 'Downloading...'
            } else {
                $downloadedBytes = (Get-Item $outfile).Length
                $downloadedMb = [math]::Round($downloadedBytes / 1MB, 2)
                $percentComplete = [math]::Round(($downloadedBytes / $fileSizeBytes) * 100, 2)
                Write-Progress (Split-Path $outfile -Leaf) 'Downloading...' -PercentComplete $percentComplete -CurrentOperation "$uri : $downloadedMb MB / $fileSizeMb MB"
            }
        }
        
        # Cleanup job
        Wait-Job $downloadJob | Remove-Job | Out-Null
        Write-Progress (Split-Path $outfile -Leaf) 'Downloading...' -Completed

        # Return [System.IO.FileInfo] object
        Get-Item $outfile
    }
}