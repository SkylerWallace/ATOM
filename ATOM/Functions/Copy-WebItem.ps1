function Copy-WebItem {
    <#
    .SYNOPSIS
    Downloads a file from a specified URL and displays a progress bar.

    .DESCRIPTION
    The `Copy-WebItem` function downloads a file from a specified URL to a target file path. It supports custom HTTP headers, progress reporting, and an option to prevent overwriting existing files.

    .PARAMETER Uri
    Specifies the URL to download the file. Alias: 'Url'.

    .PARAMETER OutFile
    Specifies the path where the downloaded file will be saved. If not specified, the file will be saved in the system's TEMP directory with a name derived from the URL. Optional.

    .PARAMETER Headers
    Specifies a hashtable of custom headers to include in the HTTP request. Useful for providing authentication tokens or other headers required by the server. Optional.

    .PARAMETER UserAgent
    Specifies a user agent string for the web request. The default user agent is `Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) Gecko/20100401 Firefox/4.0`.

    .PARAMETER Force
    Creates the parent directory of the specified output file if it does not exist. Without this parameter, an error is generated if the parent directory does not exist.

    .PARAMETER NoClobber
    Prevents overwriting an existing file if it already exists at the specified path. If the file exists and has the same length as the remote file, an error is generated instead of downloading again.

    .PARAMETER NoProgress
    Suppresses the download progress bar and progress tracking. Useful when downloading multiple small files.

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
    "https://example.com/file1.zip","https://example.com/file2.zip" | Copy-WebItem -OutFile "C:\Temp\" -Force
    Downloads multiple files from the pipeline and saves them to `C:\Temp\`, creating the directory if not present, using their original file names.

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

    [CmdletBinding(SupportsShouldProcess)]

    param (
        [Alias('Url')][Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [String]$Uri,
        [Parameter(Position = 1)]
        [String]$OutFile,
        [Hashtable]$Headers = $null,
        [String]$UserAgent,
        [PsCredential]$Credential = $null,
        [Switch]$Force,
        [Switch]$NoClobber,
        [Switch]$NoProgress
    )

    begin {
        # Load System.Net.Http assembly if not already loaded
        Add-Type -AssemblyName System.Net.Http

        # Load Utility Module if PSUserAgent class is undefined
        if (!('Microsoft.PowerShell.Commands.PSUserAgent' -as [type])) {
            Write-Verbose "Microsoft.PowerShell.Commands.PSUserAgent class undefined, loading Microsoft.PowerShell.Utility module."
            Import-Module Microsoft.PowerShell.Utility
        }
    }

    process {
        # Set UserAgent to FireFox if undefined
        if (!$UserAgent) {
            Write-Verbose "UserAgent parameter undefined, setting to FireFox."
            $UserAgent = 
                if ('Microsoft.PowerShell.Commands.PSUserAgent' -as [type]) { [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox }
                else { 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) Gecko/20100401 Firefox/4.0' }
        }

        # Create HTTP client
        try {
            $handler = [System.Net.Http.HttpClientHandler]::new()

            if ($Credential) {
                $handler.Credentials = $Credential.GetNetworkCredential()
            }

            $httpClient = [System.Net.Http.HttpClient]::new($handler)
            $httpClient.DefaultRequestHeaders.UserAgent.ParseAdd($UserAgent)

            # Add custom headers
            if ($Headers) {
                foreach ($header in $Headers.GetEnumerator()) {
                    $httpClient.DefaultRequestHeaders.TryAddWithoutValidation($header.Key,[string]$header.Value) | Out-Null
                }
            }

            # Send GET request, returning as soon as headers arrive
            Write-Verbose "Requesting download information from $Uri"

            $requestUri = [System.Uri]::new($Uri)
            $response = $httpClient.GetAsync($requestUri,[System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()

            if (!$response.IsSuccessStatusCode) {
                throw "HTTP request failed with status code $([int]$response.StatusCode) ($($response.StatusCode))."
            }

            # Get file size
            $fileSizeBytes = $response.Content.Headers.ContentLength
            $fileSizeMb = 
                if ($fileSizeBytes) { [math]::Round($fileSizeBytes / 1MB, 1) }
                else { $null }

            # Get filename (ContentDisposition)
            $fileName = $null # fileName persists through process block

            if ($response.Content.Headers.ContentDisposition) {
                $contentDisposition = $response.Content.Headers.ContentDisposition

                $fileName = 
                    if ($contentDisposition.FileNameStar) { $contentDisposition.FileNameStar }
                    elseif ($contentDisposition.FileName) { $contentDisposition.FileName }

                if ($fileName) {
                    $fileName = $fileName.Trim('"')
                }
            }

            # Get filename (AbsolutePath)
            if (!$fileName) {
                $responseUri = $response.RequestMessage.RequestUri

                if ($responseUri.AbsolutePath) {
                    $fileName = [System.IO.Path]::GetFileName($responseUri.AbsolutePath)
                }
            }

            # Get filename (couldn't gather from response)
            if (!$fileName) {
                $fileName = Split-Path $Uri -Leaf
            }

            # Change OutFile param to Destination variable so piping multiple URLs doesn't break
            $destination = 
                if (!$OutFile) { Join-Path (Get-Location) $fileName }
                elseif ($OutFile.EndsWith('\')) { Join-Path $OutFile $fileName }
                else { $OutFile }

            Write-Verbose "Destination file: $destination"

            if (!$PSCmdlet.ShouldProcess($destination, 'Download')) {
                return
            }

            # Verify parent directory exists
            $parentDirectory = Split-Path $destination -Parent

            if (!(Test-Path $parentDirectory -PathType Container)) {
                if ($Force) {
                    Write-Verbose "Creating parent directory '$parentDirectory'."
                    New-Item -Path $parentDirectory -ItemType Directory -Force | Out-Null
                } else {
                    throw "The parent directory '$parentDirectory' does not exist. Specify -Force to create it."
                }
            }

            # NoClobber, override existing file behavior
            $existingFile = if (Test-Path $destination -PathType Leaf) {
                Get-Item $destination
            }

            if ($existingFile -and $fileSizeBytes -and $existingFile.Length -eq $fileSizeBytes) {
                if ($NoClobber) {
                    $errRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.IO.IOException]::new("The file '$destination' already exists."),
                        'NoClobber',
                        [System.Management.Automation.ErrorCategory]::ResourceExists,
                        $destination
                    )

                    $errRecord.CategoryInfo.Activity = $MyInvocation.MyCommand.Name
                    Write-Error $errRecord
                    return
                }

                Write-Verbose "Overwriting '$destination' with download."
            }

            # Stream download directly to disk
            Write-Verbose "Downloading from $Uri"

            $responseStream = $response.Content.ReadAsStreamAsync().GetAwaiter().GetResult()

            $targetStream = [System.IO.FileStream]::new(
                $destination,
                [System.IO.FileMode]::Create,
                [System.IO.FileAccess]::Write,
                [System.IO.FileShare]::None,
                64KB,
                [System.IO.FileOptions]::SequentialScan
            )

            $buffer = New-Object byte[] 64KB
            $downloadedBytes = 0
            $downloadedMb = 0

            # Exponential moving average (EMA) for speed
            $emaAlpha = 0.125
            $emaBytesPerSecond = $null

            # Start timer for download
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

            # Progress update tracking
            $lastProgressUpdate = $stopwatch.Elapsed
            $lastProgressBytes = 0

            while ($true) {
                $bytesRead = $responseStream.Read($buffer, 0, $buffer.Length)

                if ($bytesRead -le 0) { break }

                $targetStream.Write($buffer, 0, $bytesRead)

                $downloadedBytes += $bytesRead
                $downloadedMb = [math]::Round($downloadedBytes / 1MB, 1)

                # If NoProgress switch param used, suppress progress bar and skip all related calculations
                if ($NoProgress) { continue }

                # Update progress approximately every 500ms
                $elapsedSinceProgress = ($stopwatch.Elapsed - $lastProgressUpdate).TotalSeconds
                if ($elapsedSinceProgress -lt 0.5) { continue }

                # Calculate current speed since previous update
                $bytesSinceProgress = $downloadedBytes - $lastProgressBytes
                $bytesPerSecond = $bytesSinceProgress / $elapsedSinceProgress
                $speedMb = [math]::Round($bytesPerSecond / 1MB, 1)
                
                # Update exponential moving average (EMA)
                $emaBytesPerSecond = 
                    if ($null -eq $emaBytesPerSecond) { $bytesPerSecond }
                    else { ($bytesPerSecond * $emaAlpha) + ($emaBytesPerSecond * (1 - $emaAlpha)) }

                # Calculate estimated time remaining
                $etaText = 
                    if ($fileSizeBytes -and $emaBytesPerSecond -gt 0) {
                        [TimeSpan]::FromSeconds(($fileSizeBytes - $downloadedBytes) / $emaBytesPerSecond).ToString('hh\:mm\:ss')
                    } else {
                        '--:--:--'
                    }

                # Format elapsed time
                $elapsedText = $stopwatch.Elapsed.ToString('hh\:mm\:ss')

                # Splat progress bar params
                $progressParams = @{
                    Activity = (Split-Path $destination -Leaf)
                    Status = 'Downloading...'
                    CurrentOperation = "Time $elapsedText | ETA $etaText | Progress $downloadedMb$(if ($fileSizeBytes) { " / $fileSizeMb" }) MB | Rate $speedMb MB/s"
                    PercentComplete = if ($fileSizeBytes) {
                        [math]::Min(100, [math]::Round(($downloadedBytes / $fileSizeBytes) * 100, 2))
                    } else { -1 }
                }

                Write-Progress @progressParams

                $lastProgressUpdate = $stopwatch.Elapsed
                $lastProgressBytes = $downloadedBytes
            }

            $stopwatch.Stop()

            # Final progress update
            $progressParams = @{
                Activity = (Split-Path $destination -Leaf)
                Status = 'Downloading...'
                Completed = $true
                CurrentOperation = "$downloadedMb MB | $($stopwatch.Elapsed.ToString('hh\:mm\:ss'))"
                PercentComplete = if ($fileSizeBytes) { 100 } else { -1 }
            }
            
            Write-Progress @progressParams
        } finally {
            # Cleanup
            if ($targetStream) { $targetStream.Flush(); $targetStream.Dispose() }
            if ($responseStream) { $responseStream.Dispose() }
            if ($response) {$response.Dispose()}
            if ($httpClient) {$httpClient.Dispose()}
        }

        # Return [System.IO.FileInfo] object
        Get-Item $destination
    }
}