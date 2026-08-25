function Get-ShadowCopies {
    <#
    .SYNOPSIS
    Outputs shadow copies of all connected drives.

    .DESCRIPTION
    The `Get-ShadowCopies` function uses WMI classes to retrieve shadow copies of all connected drives and outputs their drive letter and creation date.

    .INPUTS
    None. This function does not accept any pipeline input.

    .OUTPUTS
    None. This function does not produce output to the pipeline.
    
    .EXAMPLE
    Get-ShadowCopies
    
    .NOTES
    Author: Skyler Wallace
    #>

    # Get all drive volumes
    $volumes = Get-CimInstance Win32_Volume | Where-Object { $_.Name -match '[A-wa-w]:\\' } | Select-Object DeviceId, Name | Sort-Object Name

    if (Get-CimClass Win32_ShadowCopy -ErrorAction SilentlyContinue) {
        $shadowCopies = Get-CimInstance Win32_ShadowCopy | Where-Object { $_.VolumeName -in $volumes.DeviceId } | Select-Object DeviceObject, InstallDate, VolumeName

        $shadows = $shadowCopies | ForEach-Object {
            $shadow      = $_
            $driveLetter = $volumes | Where-Object { $_.DeviceId -eq $shadow.VolumeName } | Select-Object -Expand Name

            [PSCustomObject]@{
                Drive = $driveLetter
                Date  = $shadow.InstallDate
                Path  = $shadow.DeviceObject.Replace('?', '.') + '\'
                #Link = ''
            }
        } | Sort-Object Drive | Sort-Object Date -Descending
    } else {
        # Get vssadmin path
        $vssAdmin = $volumes.Name | ForEach-Object {
            $vssPath = $_ + 'Windows\System32\vssadmin.exe'
            if (Test-Path $vssPath) {
                $vssPath
            }
        }

        # Get raw output as a single string
        $vssOutput = (& $vssAdmin list shadows).Trim() -join "`n" -split "`n`n"

        $shadows = $vssOutput[1..($vssOutput.Count - 1)] | ForEach-Object {
            if ($_ -match 'Original Volume: \(([A-wa-w]:)\)') {
                $drive = $matches[1] + "\"
            }

            if ($_ -match 'creation time: (.+)') {
                $date = $matches[1]
            }

            if ($_ -match 'Shadow Copy Volume: (.+)') {
                $path = $matches[1].Replace('?', '.') + '\'
            }

            [PSCustomObject]@{
                Drive = $drive
                Date  = $date
                Path  = $path
            }
        }
    }

    $shadows
}