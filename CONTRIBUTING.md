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

## WPF conventions

Import `AtomWpfModule.psm1`, then use `New-AtomWindow` for new windows. It supplies shared theme resources and title-bar behavior.

```powershell
$contentXaml = @'
<TextBlock Text="Plugin content" Margin="16"
           Foreground="{DynamicResource backgroundText}"/>
'@

$window = New-AtomWindow -Title 'My Plugin' -ContentXaml $contentXaml
$window.ShowDialog() | Out-Null
```

Standard names exposed through `FindName()` are `atomTitle`, `atomContent`, `atomMinimizeButton`, `atomCloseButton`. Existing windows can migrate one at a time.

## Suggested 3.0.0 release checks

1. Set and validate the version.
2. Parse every `.ps1` and `.psm1` file.
3. Run PSScriptAnalyzer and review new warnings.
4. Smoke-test ATOM and each first-party WPF plugin on Windows PowerShell and PowerShell 7.
5. Create release notes, tag `v3.0.0`, and build `ATOM.zip` from that tag.
