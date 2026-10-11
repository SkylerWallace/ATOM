# Contributing to ATOM

## Releases and versioning

ATOM follows Semantic Versioning (`MAJOR.MINOR.PATCH`). The single source of truth is `ATOM/Config/Version.psd1`; do not hard-code the release version in scripts or UI.

- `MAJOR`: incompatible behavior or plugin API changes.
- `MINOR`: backward-compatible features.
- `PATCH`: backward-compatible fixes.
- Git tags and display text use a `v` prefix (`v3.0.0`); the stored value does not.

Set a release version with:

```powershell
./ATOM/Dependencies/Set-AtomVersion.ps1 3.0.0
```

## PowerShell conventions

- Functions use approved PowerShell `Verb-SingularNoun` names.
- Parameters and public variables use `PascalCase`; local variables use `camelCase`.
- Prefer full command and parameter names in committed code.
- Use single quotes for literal strings and double quotes only for interpolation.
- Public functions include comment-based help and typed parameters.
- Avoid aliases, global state, and one-letter names outside small index loops.
- New code should pass the PowerShell parser and PSScriptAnalyzer before release.

Apply these rules when touching a file; migrate older code incrementally instead of combining a release with a repository-wide rename.

## Plugin identity

Every built-in entry in `ATOM/Config/Plugins.ps1` has a permanent `Id`: a
GUID formatted as 32 hexadecimal characters. Generate one for a new plugin with
`[Guid]::NewGuid().ToString('N')`. Keep that ID when renaming or moving the plugin;
never derive it from a filename or reuse an ID for a different plugin.

`PluginsUser.ps1` keys preferences and registered user metadata by ID. User plugins
receive an ID when created or registered, and retain it when renamed through
Properties. Pre-4.0 name-based entries are ignored. Catalog loading rejects invalid
or duplicate built-in IDs.

Plugin-backed entries in `WorkflowActions.psd1` reference that ID as `PluginId`.
Keep the workflow action's own key separate from the plugin ID; multiple actions
can use the same plugin with different parameters. `PluginFile` is used only for
actions without an ID. An unresolved ID fails validation and never falls back to
a possibly unrelated file.

Unmanaged launcher files receive a saved identity when preferences are first
configured. Files dropped directly into `Plugins` remain discoverable without
registration.

## Adding an official plugin

1. Run ATOM from your repository checkout and choose **Add plugin** from the
   right-click menu.
2. Enter its name, script type, category, description, and supported environments.
   Optionally choose a script to copy and an icon.
3. Select **Official ATOM plugin** and accept the confirmation, then click
   **Create**. The option is off by default.
4. Use **Open in Editor** to implement or review the script. Review the new entry
   in `ATOM/Config/Plugins.ps1` and any icon under `ATOM/Plugins/<name>/`.
5. Test the plugin, review the Git diff, and commit its script, catalog entry, and
   icon together. Creating it locally does not publish it or make a commit.

ATOM generates the permanent ID automatically. Official definitions are stored
in `Plugins.ps1`, and their icons use a tracked location. They are read-only in
Properties and cannot be deleted through ATOM; maintain them in the source files.
Updates or repairs can replace catalog changes that have not shipped, so work
from your development checkout. Leave `CHANGELOG.md` unchanged until release.

## WPF conventions

Dot-source `Functions/Import-Atom.ps1` with `-Feature Wpf`, then use `New-AtomWindow` for new windows. It supplies shared theme resources and title-bar behavior. See the [function library guide](ATOM/Functions/README.md) for organization, dependencies, worker imports, and compatibility.

```powershell
. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Feature Wpf

$contentXaml = @'
<TextBlock Text="Plugin content" Margin="16"
           Foreground="{DynamicResource backgroundText}"/>
'@

$window = New-AtomWindow -Title 'My Plugin' -ContentXaml $contentXaml
$window.ShowDialog() | Out-Null
```

Standard names exposed through `FindName()` are `atomTitle`, `atomContent`, `atomMinimizeButton`, `atomCloseButton`. Existing windows can migrate one at a time.
