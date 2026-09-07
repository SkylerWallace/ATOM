function Invoke-Runspace {
    [CmdletBinding()]
    param (
        [ScriptBlock]$ScriptBlock,

        [Hashtable]$InputVariables,

        [Switch]$Isolated,

        [Switch]$Wait
    )

    $runspace = [RunspaceFactory]::CreateRunspace()
    $runspace.ApartmentState = 'STA'
    $runspace.ThreadOptions = 'ReuseThread'
    $runspace.Open()

    # Import all script's variables into runspace
    if (!$Isolated) {
        Get-Variable | Where-Object { $_.Options -eq 'None' } | ForEach-Object {
            $runspace.SessionStateProxy.SetVariable($_.Name, $_.Value)
        }
    }
    if ($InputVariables) {
        foreach ($entry in $InputVariables.GetEnumerator()) {
            $runspace.SessionStateProxy.SetVariable($entry.Key, $entry.Value)
        }
    }
    
    # Create scriptblock for Write-OutputBox and Invoke-Ui functions
    $additionalScriptBlock = {
        function Invoke-Ui {
            param (
        [ScriptBlock]$Action,

        [Switch]$GetValue
    )

            if ($GetValue) { return $window.Dispatcher.Invoke([Func[Object]]$Action) }
            $window.Dispatcher.Invoke([Action]$Action, 'Render')
        }

        function Write-Host {
            param (
        [String]$Object
    )

            Microsoft.PowerShell.Utility\Write-Output $Object
            Invoke-Ui {
                $outputBox.Text += "$Object`r`n"
                if ($outputScrollViewer) {
                    $outputScrollViewer.ScrollToEnd()
                }
            }
        }
    }
    
    # Modify scriptblock parameter to include Write-OutputBox function
    $scriptBlock = [ScriptBlock]::Create([String]$additionalScriptBlock + "`n" + [String]$ScriptBlock)
    
    # Add scriptblock
    $powershell = [powershell]::Create().AddScript($scriptBlock)
    
    # Start runspace
    $powershell.Runspace = $runspace

    if ($wait) {
        $handle = $powershell.BeginInvoke()
        $powershell.EndInvoke($handle)
        $result = $powershell.Streams.Output
        $powershell.Dispose()
        [GC]::Collect()
        return $result
    } else {
        $null = $powershell.BeginInvoke()
    }
}
