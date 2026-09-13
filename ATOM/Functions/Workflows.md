# Workflow foundation

Status: initial action-based slice implemented. Larger preset cards appear above action cards, with an independently scrolling queue anchored at the bottom. Add by button or drag; reorder by buttons or drag. Presets replace the queue after confirmation. Queue editing is locked during execution.

The Windows diagnostics preset combines a built-in Windows information command and Trifecta's `-Action VerifySystemFiles -NonInteractive` entry point. The latter runs `sfc /verifyonly`, waits for completion, and preserves output and exit code. It reports NeedsAttention for review rather than inferring system health from an undocumented exit-code convention. NeedsAttention stops subsequent steps. Both actions currently target running Windows only; SFC requires elevation. Normal Trifecta launches retain their existing behavior.

Definitions live in `Config/WorkflowActions.psd1` and `Config/WorkflowPresets.psd1`. Queue entries have independent IDs so duplicates can be moved separately. The worker validates the entire queue before running any action, resolves plugin parameters from the trusted catalog, and saves per-step JSON checkpoints in `Logs/Workflows`. Editable action options, preset authoring, and reboot continuation remain future work.

SFC reference: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/sfc

The remaining sections describe the intended expansion.

## Vocabulary

A **workflow** is an ordered sequence of steps. An **action** is one supported operation, such as a quick scan or restoring service startup defaults. A **preset** supplies a reusable workflow; a **run** is one execution with its own results. Keep Workflows as the page name: Automation describes the mechanism, while Workflows describes what users build.

## Suggested organization

Follow the existing one-function-per-file loader and dependency index:

- `Config/WorkflowActions.psd1`: first-party action definitions, stable IDs, labels, descriptions, typed option schemas, prerequisites, environment support, and adapter IDs.
- `Config/WorkflowPresets.psd1`: built-in ordered steps referencing action IDs and option values. Do not duplicate executable paths or command-line arguments here.
- `Functions/Workflows`: validation, planning, orchestration, process execution, and result persistence; no WPF dependency.
- `Functions/Workflows/Adapters`: small tool-specific functions that translate validated options into invocation arguments and interpret results.
- `Launcher/Workflows`: page construction and UI event handling.
- `Config/WorkflowsUser.json`: user-created presets and overrides, excluded from version control and updater ownership.
- `Logs/Workflows/<run-id>`: run snapshot, structured step results, and separate stdout/stderr logs. Add retention and atomic checkpoint writes when execution is introduced.

Load definitions and adapters only when requested. The placeholder starts no workers, scans, or program discovery. Eventually build the full page on first use; create one background runner only when a run starts. Send bounded progress updates to the dispatcher instead of rebuilding controls for each output line.

## Actions and third-party switches

Keep program identity, download information, and executable resolution in the existing program catalog. Store workflow-specific behavior alongside its adapter, not in plugin ToolTip/Description fields and not in a central free-form command string.

Each tool adapter should document the official CLI reference, tested versions, supported editions/licensing, argument mapping, working directory, exit-code meanings, output/report handling, cancellation behavior, and whether it actually waits for completion. Unknown versions or unsupported capabilities must be reported before starting; do not infer that every portable scanner has an unattended interface.

Emsisoft and Malwarebytes need separate research and validation before registering scan actions. Their current GUI launchers are not proof of automation support. Do not invent switches or treat opening their GUI as a completed scan. Distinguish a scan that completed and found threats from one that failed. Remediation must be an explicit option, separate from scan-only behavior.

Actions expose typed choices (for example ScanType) rather than raw shell text. Adapters construct arguments using a tested Windows argument encoder compatible with Windows PowerShell 5.1; never concatenate user input into Invoke-Expression, cmd /c, or a PowerShell command expression. Reference programs by catalog ID and resolve executable paths at runtime.

## First-party plugins

Yes: add explicit noninteractive parameters to automation-capable plugins while preserving their interactive behavior when launched without parameters. Extract shared operations into focused functions so the GUI/console menu and workflow adapter invoke the same implementation.

Reset Default Services currently has only an internal Continue switch, interactive prompts, and a self-relaunch path. A proposed public contract is an Action choice (PreviewStartupDefaults or RestoreStartupDefaults), an explicit Windows target, NonInteractive, and an optional ResultPath. These names are proposals, not implemented parameters. In noninteractive mode, bypass menu/relaunch/pause code, validate the target, use terminating errors and meaningful exit codes, and clean up owned hive mounts in finally blocks. Preview and apply should share the same change calculation. Do not silently broaden restoring startup defaults into reinstalling services.

Use SupportsShouldProcess where appropriate for modifying operations. The runner reviews the resolved plan once; noninteractive steps must not hang waiting for confirmation or silently assume missing input.

## Runner contract

Start with one sequential queue. Freeze a validated plan before execution, including resolved options, action versions, prerequisites, target OS, and failure policies. Show the user what will run, especially system changes and remediation. Never execute a selected preset simply by opening it.

Each step reports Pending, Running, Succeeded, Failed, Skipped, Cancelled, or NeedsAttention, plus timestamps, exit code, summary, log paths, findings, and reboot requirements. Process exit alone is not enough if a tool starts detached work. Tool adapters must define observable completion.

Preflight checks include availability, elevation, Windows/PE compatibility, offline-target support, required connectivity, and supported tool versions. Reuse the downloader for missing prerequisites through an explicit preparation step. Do not run scans and repairs concurrently initially.

Default to stopping after failure. Allow explicit per-step continuation policy. Cancellation should stop scheduling new steps; only interrupt an active operation when its adapter supports safe cancellation. A repair that cannot be interrupted should finish its current step. Stop on reboot requirements and preserve the run; reboot/resume support can follow later, without automatic reruns of potentially destructive steps.

Persist an immutable action/options snapshot per run so subsequent preset edits cannot alter history. A restarted ATOM must label interrupted runs accurately rather than assume success or automatically repeat them. Logs may contain sensitive paths or findings; keep them local.

## First implementation slice

Implement the schema validator, sequential runner, structured results, and a single read-only action first. Then add Reset Default Services preview and explicit apply, followed by one officially documented scanner adapter. Build broader diagnostic/scan/repair presets only after each constituent action has reliable completion and failure reporting. Test with dummy executables and isolated fixtures before exercising real system-changing steps.
