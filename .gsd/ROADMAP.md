# ROADMAP.md

> **Current Phase**: Not started
> **Milestone**: v2.0 (Modular winHelp)

## Must-Haves (from SPEC)
- [ ] Modular script architecture
- [ ] Central `launcher.ps1` with CLI support
- [ ] JSON-based configuration system
- [ ] Structured logging to `/logs`
- [ ] Ported existing features (Install, Backup, Git/Fonts)
- [ ] New Debloat module
- [ ] Modern WPF UI orchestrating the above

## Phases

### Phase 1: Foundation & Core Logic
**Status**: ✅ Complete
**Objective**: Establish the new directory structure, implement the core logger, configuration system, and the central orchestration launcher.
**Requirements**: REQ-02, REQ-03, REQ-06, REQ-11, REQ-13, REQ-14

### Phase 2: Feature Porting (Core Modules)
**Status**: ✅ Complete
**Objective**: Decompose the original monolithic script and port existing features into independent modules for Software Installation, Backup/Restore, and System Configuration.
**Requirements**: REQ-01, REQ-08, REQ-09, REQ-10, REQ-12

### Phase 3: Expansion (Debloating & Updates)
**Status**: ✅ Complete
**Objective**: Implement the new Debloating module and an update checker module. Refine error handling and headless execution paths.
**Requirements**: REQ-07, REQ-05

### Phase 4: UI Integration & Polish
**Status**: ✅ Completed
**Objective**: Build/Port the WPF UI to hook into the new modular orchestrator. Finalize documentation, examples, and performance tuning.
**Requirements**: REQ-04
