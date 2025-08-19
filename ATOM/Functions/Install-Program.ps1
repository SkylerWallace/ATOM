function Install-Program {
    <#
    .SYNOPSIS
    Installs a program using a package manager or by downloading from a remote URL.

    .DESCRIPTION
    The `Install-Program` function facilitates program installation by either:
    - Installing directly from a specified local file path.
    - Downloading the installer from a specified URL (with optional headers) and installing it.
    - Extracting the installer from a ZIP archive, if applicable.

    It supports passing arguments to the installer and tracks the installation process, returning success or failure status.

    .PARAMETER Uri
    Specifies the URL to download the installer. Alias: 'Url'.

    .PARAMETER FilePath
    Specifies either the file path of the installer to run or the name of a package manager (e.g., 'winget', 'choco', 'scoop') for executing installation commands.

    .PARAMETER ArgumentList
    Specifies the arguments to pass to the installer. Optional.

    .PARAMETER Headers
    Specifies additional headers to include in the HTTP request for downloading the installer. Optional.

    .PARAMETER Description
    Specifies a custom label or description of the installation method (e.g., "winget" or "chocolatey"). Optional.

    .EXAMPLE
    Install-Program -FilePath 'winget' -ArgumentList 'install --id 7-Zip.7-Zip --accept-package-agreements --accept-source-agreements --force' -Description 'Winget'
    Installs 7-Zip using Winget package manager.

    .EXAMPLE
    Install-Program -FilePath 'choco' -ArgumentList "install 7zip -y" -Description 'Choco'
    Installs 7-Zip using Chocolatey package manager.

    .EXAMPLE
    Install-Program -FilePath 'powershell' -ArgumentList "scoop install 7zip" -Description 'Scoop'
    Installs 7-Zip using Scoop package manager through PowerShell.

    .EXAMPLE
    Install-Program -Uri 'https://example.com/app.zip' -ArgumentList '/s' -Description 'Silent Install'
    Downloads a ZIP archive containing the installer, extracts it, and installs the program using the specified arguments.

    .EXAMPLE
    Install-Program -Uri 'https://example.com/app.exe' -Headers @{ Authorization = 'Bearer token' } -Description 'API Install'
    Downloads the installer from the specified URL using an authorization header and installs it.

    .INPUTS
    None. This function does not accept any pipeline input.

    .OUTPUTS
    [bool] Returns `$true` if the installation succeeds or `$false` if it fails.

    .NOTES
    Author: Skyler Wallace
    Requires:
    - The custom function `Get-FileFromUrl` to download files from URLs.
    - Internet connection to download files.
    - Administrative privileges might be required for certain installations.
    - When using 'FilePath' for package managers, ensure the corresponding package manager is installed on the system.
    #>
    
    param (
        [Parameter(Mandatory=$true, ParameterSetName="UriSet", Position=0)]
        [Alias('Url')]
        [string]$uri,

        [Parameter(Mandatory=$true, ParameterSetName="FilePathSet", Position=0)]
        [string]$filePath,

        [string]$argumentList = $null,
        [hashtable]$headers = $null,
        [string]$description = $null
    )

    if ($uri) {
        # Download from URL
        $downloadParams = @{ Uri = $uri }
        if ($headers) { $downloadParams.Headers = $headers }
        $filePath = Get-FileFromUrl @downloadParams

        # Extract if installer is in zip
        $extension = [System.IO.Path]::GetExtension($uri)
        if ($extension -in '.zip', '.asp') {
            Expand-Archive -LiteralPath $filePath -Force
            Remove-Item $filePath -Force
            $filePath = (Get-ChildItem -Path (Get-Item $filePath).BaseName -Recurse -Filter "*.exe" | Select-Object -First 1).FullName
        }
    }

    $installParams = @{ FilePath = $filePath; Wait = $true; PassThru = $true}
    if ($argumentList) { $installParams.ArgumentList = $argumentList }

    $installProcess = Start-Process @installParams

    $text =
        if ($description) { "with $description" }
        else              { "" }

    if ($installProcess.ExitCode -in 0,1,3010) {
        Write-Host "- Installed $text"
        return $true # Return success state
    } else {
        Write-Host "- Failed to install $text"
        Write-Host "  Exit Code : $($installProcess.ExitCode)"
        return $false # Return failure state
    }
}