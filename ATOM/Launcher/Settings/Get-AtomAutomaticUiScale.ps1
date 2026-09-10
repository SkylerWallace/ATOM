function Get-AtomAutomaticUiScale {
    # WPF work-area dimensions are already in device-independent units: Windows
    # DPI scaling must not be multiplied into our additional layout scale again.
    $area = [Windows.SystemParameters]::WorkArea
    $width = $area.Width
    $height = $area.Height
    $source = [Windows.PresentationSource]::FromVisual($window)
    if ($source -and $source.Handle -ne [IntPtr]::Zero) {
        if (!('AtomDisplayWorkArea' -as [type])) {
            Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class AtomDisplayWorkArea {
    [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left, Top, Right, Bottom; }
    [StructLayout(LayoutKind.Sequential)] public struct Info { public int Size; public Rect Monitor, Work; public uint Flags; }
    [DllImport("user32.dll")] static extern IntPtr MonitorFromWindow(IntPtr window, uint flags);
    [DllImport("user32.dll", CharSet=CharSet.Auto)] static extern bool GetMonitorInfo(IntPtr monitor, ref Info info);
    public static Rect Get(IntPtr window) {
        Info info = new Info(); info.Size = Marshal.SizeOf(typeof(Info));
        if (!GetMonitorInfo(MonitorFromWindow(window, 2), ref info)) return new Rect();
        return info.Work;
    }
}
'@
        }
        $rect = [AtomDisplayWorkArea]::Get($source.Handle)
        if ($rect.Right -gt $rect.Left -and $rect.Bottom -gt $rect.Top) {
            $transform = $source.CompositionTarget.TransformFromDevice
            $width = ($rect.Right - $rect.Left) * $transform.M11
            $height = ($rect.Bottom - $rect.Top) * $transform.M22
        }
    }
    # Conservative fit: 900 logical pixels of height / 1440 of width are the
    # 100% reference. Round down so the recommendation does not overshoot.
    $candidate = [Math]::Min($width / 1440.0, $height / 900.0)
    $currentScale = [double]$window.Resources['uiScale']
    if ($window.Width -gt 0 -and $currentScale -gt 0) {
        $candidate = [Math]::Min($candidate, ($width * 0.9) / ($window.Width / $currentScale))
    }
    return [Math]::Max(1.0, [Math]::Min(2.0, [Math]::Floor($candidate * 8) / 8))
}
