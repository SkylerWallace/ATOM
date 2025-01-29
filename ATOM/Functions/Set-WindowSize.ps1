function Set-WindowSize {
	Add-Type -TypeDefinition @"
	using System;
	using System.Runtime.InteropServices;
	public class Display
	{
		[DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr hwnd);
		[DllImport("gdi32.dll")] public static extern int GetDeviceCaps(IntPtr hdc, int nIndex);
		public static int GetScreenHeight() { return GetDeviceCaps(GetDC(IntPtr.Zero), 10); }
		public static int GetScalingFactor() { return GetDeviceCaps(GetDC(IntPtr.Zero), 88); }
	}
"@
	$scalingDecimal = [Display]::GetScalingFactor()/ 96
	$effectiveVertRes = ([double][Display]::GetScreenHeight()/ $scalingDecimal)
	if ($effectiveVertRes -le (1.0 * $window.MaxHeight)) {
		$window.MinHeight = 0.6 * $effectiveVertRes
		$window.MaxHeight = 0.9 * $effectiveVertRes
	}
}