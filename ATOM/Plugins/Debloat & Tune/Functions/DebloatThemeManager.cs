// COM identifiers and vtable order: namazso's MIT-licensed IThemeManager2 investigation.
// https://gist.github.com/namazso/0fde102c2fc56049c7c37f7fdf9ac3cd
using System;
using System.Runtime.InteropServices;
namespace Atom {
    [ComImport, Guid("c1e8c83e-845d-4d95-81db-e283fdffc000")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    internal interface IThemeManager2 {
        void Init(uint flags);
        void InitAsync(IntPtr hwnd, int unused);
        void Refresh();
        void RefreshAsync(IntPtr hwnd, int unused);
        void RefreshComplete();
        void GetThemeCount(out int count);
        void GetTheme(int index, [MarshalAs(UnmanagedType.Interface)] out object theme);
        void IsThemeDisabled(int index, out int disabled);
        void GetCurrentTheme(out int index);
        void SetCurrentTheme(IntPtr parent, int index, int apply, uint flags, uint packFlags);
        void GetCustomTheme(out int index);
        void GetDefaultTheme(out int index);
        void CreateThemePack(IntPtr hwnd, [MarshalAs(UnmanagedType.BStr)] string path, uint flags);
        void CloneAndSetCurrentTheme(IntPtr hwnd, [MarshalAs(UnmanagedType.BStr)] string path, [MarshalAs(UnmanagedType.BStr)] out string result);
        void InstallThemePack(IntPtr hwnd, [MarshalAs(UnmanagedType.BStr)] string path, int unused, uint flags, [MarshalAs(UnmanagedType.BStr)] out string result, [MarshalAs(UnmanagedType.Interface)] out object theme);
        void DeleteTheme([MarshalAs(UnmanagedType.BStr)] string path);
        void OpenTheme(IntPtr hwnd, [MarshalAs(UnmanagedType.BStr)] string path, uint flags);
        void AddAndSelectTheme(IntPtr hwnd, [MarshalAs(UnmanagedType.BStr)] string path, uint flags, uint packFlags);
    }
    public static class DebloatThemeManager {
        private static IThemeManager2 Create() {
            var type = Type.GetTypeFromCLSID(new Guid("9324da94-50ec-4a14-a770-e90ca03e7c8f"), true);
            var manager = (IThemeManager2)Activator.CreateInstance(type);
            try { manager.Init(0); return manager; }
            catch { Marshal.ReleaseComObject(manager); throw; }
        }
        public static void Apply(string path) {
            var manager = Create();
            try {
                // Ignore background, cursor, desktop icons, sound, and screensaver; silent pack.
                manager.AddAndSelectTheme(IntPtr.Zero, path, 1 | 2 | 4 | 16 | 32, 4);
            } finally { Marshal.ReleaseComObject(manager); }
        }
    }
}
