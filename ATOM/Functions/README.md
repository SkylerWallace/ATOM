# ATOM function library

Functions are organized by responsibility, with one named function per file. `FunctionIndex.psd1` is the explicit map of function names, source paths, and dependencies. `Import-Atom.ps1` is the single loading entry point for built-in scripts and workers.

## Finding code

| Directory | Responsibility |
| --- | --- |
| `Applications` | Launching programs and installing through package managers |
| `Configuration` | Serializing settings and plugin overrides |
| `Core` | Shared execution infrastructure, including runspaces |
| `Downloads` | Transfers, download records, update detection, filtering, and storage measurement |
| `Files` | Atomic writes and archive extraction |
| `Updates` | ATOM release metadata, hashes, manifests, and installation state |
| `Windows` | Registry, shadow copies, environment paths, and native window operations |
| `WPF` | Reusable controls, windows, icons, and theme helpers |
| `Bootstrap` | Explicit initialization of ATOM paths, settings, and theme resources |
| `../Launcher` | ATOM window controllers, grouped by Downloads, Plugins, Settings, Updates, and Navigation |

Launcher functions depend on the main window's controls and script state. Shared functions belong in this library when their responsibility is useful outside that window. `ATOM.ps1` composes the window and wires its events. Shared static control styles are in `Resources/Styles/Controls.xaml`; this is an XAML fragment inserted into the theme resource dictionary by the WPF bootstrap.

## Loading functions

Dot-source the loader at script scope. Request the entry points your script calls; their registered dependencies are included automatically.

```powershell
. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function Start-Program -Feature Catalog
Start-Program @programs['7-Zip'].ProgramInfo
```

Features opt into initialization separately from function definitions:

| Feature | Initialization |
| --- | --- |
| None | Requested functions and their dependencies only |
| `Context` | ATOM directory variables and its temporary directory |
| `Catalog` | Context plus the program catalog and user overrides |
| `Wpf` | Context plus WPF helpers, settings, themes, image cache, and window resources |

Request both `Catalog,Wpf` for a window that also uses the program catalog. WPF-marked functions load PresentationFramework even without the Wpf feature, but themed windows need the feature's resource initialization. Shared functions that use ATOM paths as defaults can be used without Context when their explicit path parameters are supplied.

```powershell
. $functionLoader -Function New-AtomFileManifest,Test-AtomFileManifest
$files = New-AtomFileManifest -RootPath $packageRoot
Test-AtomFileManifest -RootPath $packageRoot -Files $files

. $functionLoader -Function Get-AtomDownloadStorage
Get-AtomDownloadStorage -Root $downloadRoot -Destinations @{ Tool = $toolPath }
```

Each runspace must load its own functions. Pass the loader path and required data to the worker; request its entry points once in a single call. Do not import the launcher or WPF resources into a worker that only needs file or download operations.

## Scope and performance

Definitions are dot-sourced into the caller's scope so existing launcher callbacks and `$script:` state continue to share the owning script. Importing inside a function makes definitions local to that invocation; import at script scope when later callbacks need them. Avoid globals in new shared code and prefer explicit parameters over ATOM state.

The loader walks the dependency index, reads only required source files, concatenates them, and parses one script block. It preserves the previous batch-parsing optimization without recursive discovery or call-stack inspection. The index is cached in the caller's scope and refreshed when its timestamp changes. Existing function definitions are reused; `-Force` reloads definitions and the index for development. It does not unload removed functions. Feature initialization runs whenever explicitly requested, so request it once per owning script.

`-Group Launcher` loads the main window's controllers. `Runtime` and `Wpf` groups support broad entry points and compatibility; prefer individual functions for new scripts. Dependency resolution happens during import, which can move work previously deferred until the first function call into import time. File organization alone is not a startup speedup. Measure import plus first use, and distinguish that from window rendering or deferred page initialization.

## Adding or changing functions

1. Place the function in the appropriate responsibility directory, named `Verb-Noun.ps1`. Keep the file limited to its function definition and help.
2. Add its path and direct shared-function dependencies to `FunctionIndex.psd1`, including calls inside worker script blocks. Mark WPF functions with `Wpf = $true` and add the function to its appropriate group.
3. Import entry points through `Import-Atom.ps1`. Do not dot-source dependency files from inside shared functions or discover dependencies dynamically.
4. Validate parsing, dependency paths, and the affected behavior in Windows PowerShell 5.1. Exercise workers independently; they do not inherit the UI's loaded definitions.

Launcher callbacks can refer to one another, so cycles of function definitions are supported. Files must not perform work during import; side effects belong in explicit function calls or bootstrap features.

## Existing plugins

`AtomModule.psm1` and `AtomWpfModule.psm1` remain as compatibility adapters for external plugins that import those names. The former loads Runtime and the catalog by default, or the explicit `-ArgumentList` function list; the latter initializes WPF. Their implementations delegate to the same loader. Built-in plugins use the new entry point. Direct references to the former flat function paths must migrate to `Import-Atom.ps1`; those internal paths are no longer provided.
