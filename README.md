# ATOM (A Tool Of Mine)

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".github/assets/ATOM Logo (Dark).png">
    <source media="(prefers-color-scheme: light)" srcset=".github/assets/ATOM Logo (Light).png">
    <img alt="ATOM logo" src=".github/assets/ATOM Logo (Light).png" width="560">
  </picture>
</p>

ATOM is a portable Windows toolkit and launcher for PowerShell scripts, batch files, executables, and repair utilities. It brings common technician workflows into one searchable, customizable WPF interface and can be used from Windows, Windows PE, or Windows RE.

<!-- Screenshot maintainer note: update this image after the ATOM 3.0.0 interface is finalized. -->
![ATOM main window](.github/assets/ATOM%20image.png)

## What ATOM provides

- A single interface for diagnostic, repair, deployment, and maintenance tools
- Searchable plugins organized by category, with favorites and hidden-plugin controls
- Built-in and user-defined plugins without requiring changes to the main launcher
- Download management for supported portable programs
- Configurable themes, UI scaling, startup columns, launch behavior, and other preferences
- Windows PE and Windows RE support for offline repair workflows
- First-party utilities such as ATOM Notes, ATOM Store, ATOMizer, Bulk App Installer, and Windows Debloat & Tune

## Requirements

- A Windows environment capable of running WPF
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

To test the newest changes, download the [current development snapshot](https://github.com/SkylerWallace/ATOM/archive/refs/heads/dev.zip). Development builds may contain incomplete or untested work; use a tagged release when reliability is more important than receiving the newest changes.

### One-line remote launch

```powershell
irm https://tinyurl.com/run-atom | iex
```

This command downloads and immediately executes a remote script. Review the source first if you do not trust the endpoint; the release archive is the safer and more reproducible installation method.

## Using ATOM

- Use the search field to find plugins by name. Tag searching can be enabled in Settings.
- Switch between category and alphabetical sorting from the main window.
- Right-click a plugin to favorite or unfavorite it, hide or unhide it, or view its properties.
- Open Settings to choose whether plugins launch with a single click or double-click.
- Use the visibility control to show plugins that are hidden by default.
- Use download mode to select and retrieve supported external programs.

Many included plugins perform administrative or destructive maintenance operations. Read a plugin's description, confirm its options, and keep a current backup before making system-wide changes.

## Recommended portable setup

ATOM works well as a technician toolkit on a USB drive. Place the repository or release contents at the drive root and add portable applications under `Programs`. The launcher resolves its paths relative to its own location, so the drive letter can change between computers.

PowerShell Core may also be placed at `Programs\Powershell Core_x64\powershell.exe` for environments where the system Windows PowerShell executable is unavailable.

## Windows PE and Windows RE

When ATOM is stored at the root of a flash drive containing a supported Windows PE environment, the **PE** title-bar action can restart the computer into that environment.

To start ATOM after booting into Windows PE or Windows RE:

1. Open Command Prompt.
2. Run `diskpart`.
3. Run `list volume` and identify the drive containing ATOM.
4. Run `exit`.
5. Change to that drive, for example `D:`.
6. Run `ATOM.bat`.

ATOM exposes a **MountOS** action in PE/RE so the offline Windows installation can be mounted for plugins that support offline repair.

## Settings and appearance

Open Settings from the main window to configure:

- Theme and theme-specific gradient and shadow styling
- UI scaling from 1.0x through 1.5x
- Plugin launch behavior and startup column count
- Tooltips, tag searching, hidden plugins, debug mode, and restart behavior

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

Plugins without a `Category` are shown under **Uncategorized**. Common metadata fields include:

| Field | Purpose |
| --- | --- |
| `Category` | Groups the plugin in category sorting mode |
| `Tags` | Adds searchable descriptive terms when tag searching is enabled |
| `Aliases` | Adds alternate searchable names |
| `ToolTip` | Describes the plugin on hover |
| `Hidden` | Hides the plugin unless hidden plugins are shown |
| `Silent` | Controls whether its console window is suppressed |
| `WorksInOs` | Indicates support for a normal Windows session |
| `WorksInPe` | Indicates support for Windows PE or Windows RE |
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
