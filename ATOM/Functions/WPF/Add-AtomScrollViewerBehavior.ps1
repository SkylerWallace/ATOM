function Add-AtomScrollViewerBehavior {
    <#
    .SYNOPSIS
        Enables consistent mouse-wheel scrolling for named WPF ScrollViewers.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Windows.Window]$Window,

        [Parameter(Mandatory)]
        [String[]]$Name
    )

    foreach ($controlName in $Name) {
        $scrollViewer = $Window.FindName($controlName)
        if ($scrollViewer -isnot [System.Windows.Controls.ScrollViewer]) {
            throw "The control '$controlName' is not a ScrollViewer in window '$($Window.Title)'."
        }

        $mouseWheelHandler = [System.Windows.Input.MouseWheelEventHandler]{
            param($sender, $eventArgs)

            $sender.ScrollToVerticalOffset($sender.VerticalOffset - $eventArgs.Delta)
        }

        $scrollViewer.AddHandler(
            [System.Windows.UIElement]::MouseWheelEvent,
            $mouseWheelHandler,
            $true
        )
    }
}
