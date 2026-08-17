function Set-WindowStyle {

    [CmdletBinding(DefaultParameterSetName='ByProcessId')]

    param (
        [Alias('Id')][Parameter(Mandatory, ParameterSetName='ByProcessId', ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [Int]$processId,
        [Parameter(Mandatory, ParameterSetName='ByHandle')]
        [Int]$handle,
        [Parameter(Mandatory, Position = 1)]
        [ValidateSet('Normal', 'Hidden', 'Minimized', 'Maximized')]
        [string]$windowStyle
    )

    begin {
        $windowValue = switch ($windowStyle) {
            'Hidden'    { 0 }
            'Normal'    { 1 }
            'Minimized' { 2 }
            'Maximized' { 3 }
        }

        Add-Type -TypeDefinition @'
        using System;
        using System.Collections.Generic;
        using System.Runtime.InteropServices;
        using System.Text;
        public class WindowFinder {
            [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
            [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
            [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)]
            public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
            [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
            [DllImport("user32.dll")] public static extern IntPtr GetWindow(IntPtr hWnd, uint uCmd);
            [DllImport("user32.dll")] public static extern IntPtr GetParent(IntPtr hWnd);
            [DllImport("user32.dll")] public static extern long GetWindowLong(IntPtr hWnd, int nIndex);
            [DllImport("user32.dll", CharSet = CharSet.Auto)] public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
            [DllImport("user32.dll", CharSet = CharSet.Auto)] public static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);
            public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
            public static List<IntPtr> GetWindowHandlesForProcess(int processId) {
                List<IntPtr> handles = new List<IntPtr>();
                EnumWindows(delegate(IntPtr hWnd, IntPtr param) {
                    uint pid;
                    GetWindowThreadProcessId(hWnd, out pid);
                    if (pid == processId) {
                        // Filter for main windows: no owner, no parent, and has caption style (WS_CAPTION = 0x00C00000)
                        IntPtr owner = GetWindow(hWnd, 4); // GW_OWNER = 4
                        IntPtr parent = GetParent(hWnd);
                        long style = GetWindowLong(hWnd, -16); // GWL_STYLE = -16
                        if (owner == IntPtr.Zero && parent == IntPtr.Zero && (style & 0x00C00000L) != 0) {
                            StringBuilder className = new StringBuilder(256);
                            GetClassName(hWnd, className, 256);
                            string classStr = className.ToString();
                            handles.Add(hWnd);
                        }
                    }
                    return true;
                }, IntPtr.Zero);
                return handles;
            }
        }
'@
    }

    process {
        if ($processId) {
            # Find filtered window handles for the given process ID (includes hidden windows)
            write-host $processId.gettype()
            $handles = [WindowFinder]::GetWindowHandlesForProcess([Int]$processId)
            if ($handles.Count -eq 0) {
                Write-Error "No qualifying main window handles found for process ID $processId."
                return
            }

            # Filter to a single handle
            $handle = $handles | Where-Object { 
                $titleSb = New-Object System.Text.StringBuilder 256
                [WindowFinder]::GetWindowText($_, $titleSb, 256) | Out-Null
                $titleSb.ToString() -ne ''  # Select handles with non-empty titles
            } | Select-Object -First 1
        }

        # Diagnostic output for detected handles (toggle with -Verbose)
        if ($processId -and $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
            foreach ($h in $handles) {
                $titleSb = New-Object System.Text.StringBuilder 256
                [WindowFinder]::GetWindowText($h, $titleSb, 256) | Out-Null
                $title = $titleSb.ToString()

                $classSb = New-Object System.Text.StringBuilder 256
                [WindowFinder]::GetClassName($h, $classSb, 256) | Out-Null
                $class = $classSb.ToString()

                Write-Verbose "Handle: $h, Title: '$title', Class: '$class'"
            }
        }

        # Set window style
        [WindowFinder]::ShowWindow($handle, $windowValue) | Out-Null
    }
}