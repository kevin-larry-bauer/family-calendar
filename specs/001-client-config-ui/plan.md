
# Implementation Plan: Client-Side Config UI

**Branch**: `001-client-config-ui` | **Date**: 2026-02-18 | **Spec**: [specs/001-client-config-ui/spec.md](specs/001-client-config-ui/spec.md)
**Input**: Feature specification from [specs/001-client-config-ui/spec.md](specs/001-client-config-ui/spec.md)

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Primary requirement: Move all calendar/quote configuration to a client-side UI, storing values in localstorage. Remove server config and legacy scripts. Provide a new startup script for kiosk mode (Chrome, no cursor).

Technical approach: Implement a Nuxt.js page for config, use browser localstorage for persistence, and create a shell script for kiosk startup. Remove all install/startup scripts except the new one.

## Technical Context

**Language/Version**: TypeScript (Nuxt.js, Vue 3)  
**Primary Dependencies**: Nuxt.js, Vue 3, localstorage API, shell scripting (for startup)  
**Storage**: Browser localstorage  
**Testing**: Vitest (unit), Playwright (e2e) for Nuxt 3 config UI  
**Target Platform**: Raspberry Pi (for kiosk), any browser (for config UI)  
**Project Type**: Web app (single project)  
**Performance Goals**: <200ms config load, <1s Chrome startup  
**Constraints**: Client-side only, no server config, persistent localstorage, Chrome must launch in kiosk mode with no cursor  
**Scale/Scope**: Single-page config UI, 1-10 calendar URLs, 1 quote file URL, single startup script


## Constitution Check

GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.

- Library-First: UI and script are modular and independently testable.
- CLI Interface: Startup script exposes CLI for launching Chrome.
- Test-First: Tests will be written and approved before implementation (Vitest for unit, Playwright for e2e, script test for kiosk).
- Integration Testing: Integration tests for config UI and script.
- Observability & Simplicity: Logging for script errors, simple UI, versioning for script.

All gates satisfied. Testing framework clarified: Vitest (unit), Playwright (e2e).

## Research Findings

- **Testing**: Use Vitest for unit tests, Playwright for e2e tests (Nuxt 3 recommended).
- **Chrome Kiosk Script**: Use `unclutter` to hide cursor and launch Chromium with kiosk flags. See research.md for script details.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

src/
tests/
ios/ or android/
directories captured above]

```text
app.vue
pages/
  index.vue
  config.vue   # New config page for calendar/quote URLs
assets/
  css/
    main.css
public/
server/        # Will be removed if not needed
startup-kiosk.sh  # New startup script for Chrome kiosk mode
```

**Structure Decision**: Nuxt.js single-project structure. New config.vue page for calendar/quote URLs. All server/startup scripts removed except startup-kiosk.sh.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
