# ATOM (A Tool Of Mine)

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".github/assets/ATOM Logo (Dark).png">
    <source media="(prefers-color-scheme: light)" srcset=".github/assets/ATOM Logo (Light).png">
    <img alt="ATOM logo" src=".github/assets/ATOM Logo (Light).png" width="560">
  </picture>
</p>

ATOM is a portable Windows toolkit and launcher for PowerShell scripts, batch files, executables, and repair utilities. It brings common technician workflows into one searchable, customizable WPF interface and can be used from Windows, Windows PE, or Windows RE.

![ATOM main window](.github/assets/ATOM%20image.png)

## What ATOM provides

- A single interface for diagnostic, repair, deployment, and maintenance tools
- Searchable plugins organized by category, with favorites and hidden-plugin controls
- Built-in and user-defined plugins without requiring changes to the main launcher
- Download, update, and removal management for supported portable programs
- Stable and Development update channels with built-in file-integrity verification
- Configurable themes, UI scaling, startup columns, launch behavior, and other preferences
- Windows PE and Windows RE support for offline repair workflows
- First-party utilities such as ATOM Notes, ATOMizer, Bulk App Installer, and Windows Debloat & Tune

## Requirements

- A Windows environment capable of running WPF (Windows Presentation Framework)
- Windows PowerShell 5.1, which is included with supported Windows versions
- Administrator access for ATOM's elevated launcher and for plugins that modify the system

Some plugins download third-party tools or require an internet connection. Other plugins can run entirely from the local `Programs` directory.

## Download and launch

### Latest release (recommended)

1. Download the [latest ATOM release](https://github.com/SkylerWallace/ATOM/releases/latest/download/ATOM.zip).
2. Extract the archive to a writable folder or the root of a USB drive.
3. Run `ATOM.bat`.
4. Accept the Windows elevation prompt.

ATOM launches with Windows PowerShell and uses an execution-policy bypass for its own process. It does not change the computer's permanent PowerShell execution policy.

### Development build

To test the newest changes, download the [current development snapshot](https://github.com/SkylerWallace/ATOM/releases/download/dev-snapshot/ATOM-dev.zip). Development builds may contain incomplete or untested work; use a tagged release when reliability is more important than receiving the newest changes.

GitHub's **Code > Download ZIP** archive is also usable, but it does not contain packaged-build metadata. ATOM treats it as an unmanaged source copy, records its initial files on first launch, and performs a non-destructive synchronization on its first update. Files that cannot be proven to belong to ATOM are preserved.

Packaged builds contain a per-file integrity manifest. Before an update is applied, ATOM validates the downloaded package and backs up files that may be removed or replaced under `ATOM\Backups\Updates`. User-added files with unique paths are left in place; path collisions are recorded in the update backup.

### One-line remote launch

```powershell
irm https://tinyurl.com/run-atom | iex
```

This command downloads and immediately executes a remote script. Review the source first if you do not trust the endpoint; the release archive is the safer and more reproducible installation method.

## Using ATOM

- Use the search field to find plugins by name or alias. Tag searching can be enabled in Settings.
- Switch between category and alphabetical sorting from the main window.
- Right-click a plugin to manage its visibility or favorite state, open its file location, edit supported scripts, or view its properties.
- Open Settings to choose whether plugins launch with a single click or double-click.
- Use the visibility control to show plugins that are hidden by default.
- Use Download Mode to download supported external programs for offline use. An offline icon identifies downloaded programs; right-click one and select **Remove Offline Download** to remove its portable files without removing its plugin.

### Keyboard shortcuts

| Shortcut | Action |
| --- | --- |
| `Ctrl+F` | Focus plugin search |
| `F5` | Refresh the plugin list |
| `Ctrl+,` | Open Settings |
| `Alt+Left` | Return from Settings to plugins |
| Arrow keys | Navigate visible plugins |
| `Home` / `End` | Focus the first or last visible plugin |
| `Enter` | Launch the focused plugin; from Search, launch the only matching result |
| `Space` | Favorite or unfavorite a plugin; in Download Mode, toggle its selection |
| `Shift+F10` or Menu | Open the focused plugin's context menu |
| `Alt+Enter` | Open plugin properties |
| `Ctrl+A` | Select all eligible programs in Download Mode |
| `Esc` | Close the current menu or view, clear Search, or leave Download Mode |

Many included plugins perform administrative or destructive maintenance operations. Read a plugin's description, confirm its options, and keep a current backup before making system-wide changes.

## Recommended portable setup

ATOM works well as a technician toolkit on a USB drive. Extract the release onto the drive, launch ATOM, and use the **Download Mode** button in the main window to prepare the portable toolkit:

1. Enter Download Mode (download icon in the search bar cluster).
2. Select the programs you want available offline.
3. Click **Download Selected**.

ATOM downloads and extracts supported programs into the `Programs` directory automatically. You do not need to locate or place these applications manually. Because ATOM resolves this directory relative to its own location, the toolkit continues to work when the USB drive receives a different drive letter.

Select **Windows PE ISO** in Download Mode to create ATOM's bootable ISO. Selecting an entry also selects its available, missing dependencies; clearing a dependency clears entries that require it. Dependencies can also be selected independently. ATOM automatically prepares any missing dependencies first: portable PowerShell Core and the **Windows PE Build Kit**. The build kit resolves the current compatible AMD64 release from Microsoft Learn, verifies Microsoft signatures, downloads the offline packages, and extracts the required components without installing the ADK.

Reusable Microsoft inputs are tracked separately under `Programs\Windows PE Build Kit`. This curated kit contains the clean WinPE image, base media, ISO boot tools, required optional-component packages, and a hash manifest; temporary installers, offline layouts, extraction logs, and redundant architecture files are removed. The generated `ATOM-PE.iso` and its manifest remain under `Programs\Windows PE`. Updating ATOM's customization therefore rebuilds the ISO from the local kit, while a new Microsoft PE release updates the build kit first. Administrative approval is required for MSI extraction and image servicing, but ATOM never automatically uninstalls an existing ADK or formats a USB drive.

The Windows PE download creates a bootable ISO with both legacy BIOS and UEFI boot entries. The ISO can be selected from Ventoy while ATOM remains at the root of the physical USB drive. Keep `ATOM.bat`, the `ATOM` folder, and `Programs\PowerShell Core_x64` at that root so Windows PE can locate and launch ATOM automatically.

The ISO contents may also be extracted directly to a blank FAT32 flash drive. The extracted layout is immediately suitable for UEFI boot. For legacy BIOS boot, the target partition must additionally be marked active and have NT60-compatible boot code; copying files alone does not configure those disk-level properties.

Downloading **PowerShell Core** is strongly recommended for a portable installation. Windows PE and Windows RE do not normally include Windows PowerShell, so `ATOM.bat` prefers the downloaded runtime at `Programs\PowerShell Core_x64\powershell.exe` in PE. PowerShell Core is offered only in Download Mode and does not occupy space in ATOM's normal plugin list.

In Windows PE, `ATOM.bat` runs `ATOM.ps1` directly with PowerShell's `-File` mode, avoiding the normal Windows settings-and-elevation bootstrap scope. Normal Windows launches retain the existing elevated child-process behavior.

The embedded startup command records drive discovery and launch status in `X:\Windows\Temp\ATOM-PE-Startup.log`, copies it to `ATOM\Logs\Windows PE Startup.log`, and launches ATOM asynchronously in a separate `cmd.exe /k` window. The original PE shell stops at `pause` and then remains open as an interactive troubleshooting prompt. An ATOM or PowerShell failure therefore cannot close the original shell, while its error remains visible in the separate ATOM command window.

ATOM-prepared images configure `cmd.exe /d /k %SystemRoot%\System32\startnet.cmd` as the registry-level WinPE shell. Because this persistent command prompt is the top-level process, a crash or failed launch below it cannot end the PE session. The computer remains at a troubleshooting prompt until the user explicitly restarts or shuts it down.

## Windows PE and Windows RE

When ATOM is stored at the root of a flash drive containing a supported Windows PE environment, the **Reboot to PE** plugin is available to restart the computer into that environment.

To start ATOM after booting into Windows PE or Windows RE:

1. Open Command Prompt.
2. Change to the drive containing drive, typically `D:`.
3. Run `ATOM.bat`.
   - Use `cmd /c ATOM.bat` to resolve issues with Command Prompt in Windows RE not returning to troubleshooting options.

ATOM exposes a **MountOS** action in PE/RE so the offline Windows installation can be mounted for plugins that support offline repair.

## Settings and appearance

Open Settings from the main window to configure:

- Theme and theme-specific gradient and shadow styling
- UI scaling from 1.0x through 1.5x
- Plugin launch behavior and startup column count
- Plugin editor selection, tooltips, tag searching, and hidden plugins
- Quip visibility, tone, and rarity behavior
- Stable or Development update channel
- Debug mode, restart behavior, and other general preferences

The Updates section can check for and install channel updates without requiring Git. Use **Verify ATOM Files** to compare the current installation against its packaged manifest while leaving user-added files alone.

Default values live in `ATOM\Config\Settings.ps1`. User changes are stored separately in `ATOM\Config\SettingsUser.ps1`, which keeps local preferences out of the main defaults.

Themes are defined in `ATOM\Config\Themes.ps1`. Each theme can control its colors, gradient style and geometry, and shadow color, opacity, blur, depth, and direction.

## Adding a custom plugin

ATOM discovers supported scripts and executables from the `ATOM\Plugins` directory. User metadata belongs in `ATOM\Config\PluginsUser.ps1`, allowing local additions to remain separate from the built-in catalog.

1. Add the `.ps1`, `.bat`, or supported executable to `ATOM\Plugins`.
2. Give the file the same base name that you want displayed in ATOM.
3. Add a matching entry to the `$userPrograms` hashtable in `ATOM\Config\PluginsUser.ps1`.
4. Optionally add a PNG icon named after the plugin to `ATOM\Resources\Icons\Program Icons`.
5. Restart ATOM, or use the refresh action if available.

Example:

```powershell
$userPrograms = [ordered]@{
    'Example Tool' = @{
        Category  = 'Diagnostics'
        Tags      = @('Hardware', 'Testing')
        Aliases   = @('Example')
        ToolTip   = 'Describe what the tool does'
        WorksInOs = $true
        WorksInPe = $false
    }
}
```

ATOM stores user-defined plugin metadata and interface changes in this same structure. Favoriting, hiding, or moving a plugin updates its `Favorite`, `Hidden`, or `Category` property under the matching `$userPrograms` entry; separate override hashtables are not required. Returning a built-in plugin to its default value removes that property from `PluginsUser.ps1`, and entries with no remaining overrides are removed automatically.

Plugins without a `Category` are shown under **Uncategorized**. Common metadata fields include:

| Property | Usage |
| --- | --- |
| `Category` | Groups the plugin in category sorting mode |
| `Tags` | Adds searchable descriptive terms when tag searching is enabled |
| `Aliases` | Adds alternate searchable names |
| `ToolTip` | Describes the plugin on hover |
| `Hidden` | Hides the plugin unless hidden plugins are shown |
| `DownloadOnly` | Shows a downloadable program in Download Mode without requiring a launcher plugin file |
| `Silent` | Controls whether its console window is suppressed |
| `WorksInOs` | Indicates support for a normal Windows session |
| `WorksInPe` | Indicates support for Windows PE or Windows RE |
| `Dependencies` | Lists missing Download Mode entries that must be prepared first |
| `ProgramInfo` | Describes an external program's path and download source |

Use `ATOM\Config\Plugins.ps1` as the reference for more advanced entries, including portable-program downloads and custom script blocks.

## Included utilities

<details>
<summary><strong>ATOM Notes</strong> — lightweight repair-session notes</summary>

![ATOM Notes window](.github/assets/ATOM%20Notes%20image.png)

Notes are saved in `ATOM\Logs` and can be transferred to the repaired Windows installation from PE/RE.
</details>

<details>
<summary><strong>ATOMizer</strong> — prepare and update multiple USB drives</summary>

![ATOMizer window](.github/assets/ATOMizer%20image.png)
</details>

<details>
<summary><strong>Bulk App Installer</strong> — install applications through WinGet</summary>

![Bulk App Installer window](.github/assets/Bulk%20App%20Installer%20image.png)
</details>

<details>
<summary><strong>Windows Debloat & Tune</strong> — apply selected Windows cleanup and privacy changes</summary>

![Windows Debloat and Tune window](.github/assets/Windows%20Debloat%20%26%20Tune%20image.png)
</details>

<details>
<summary><strong>Ornstein & S-Mode</strong> — guide the steps required to disable Windows S mode</summary>

![Ornstein and S-Mode window](.github/assets/Ornstein%20%26%20S-Mode%20image.png)
</details>

<!-- Screenshot maintainer note: refresh the images above when each plugin adopts the finalized ATOM 3.0.0 styling. -->

## Contributing

Contributions and focused bug reports are welcome. Before changing code, read [CONTRIBUTING.md](CONTRIBUTING.md) for the project's semantic-versioning policy, PowerShell naming conventions, standardized WPF window pattern, and release checks.

When submitting a change:

1. Keep commits focused on one migration or behavior change.
2. Use approved PowerShell verb-noun function names and descriptive camelCase variables.
3. Build WPF plugin windows with the shared `New-AtomWindow` helper.
4. Run PowerShell parser checks and manually exercise the affected UI workflow.
5. Do not include local files such as `SettingsUser.ps1` or `PluginsUser.ps1` unless they are intentional examples.

Report bugs or request features through [GitHub Issues](https://github.com/SkylerWallace/ATOM/issues).

## License

ATOM is available under the [Apache License 2.0](LICENSE).
