---

description: "Task list for client-side config UI feature implementation"
---

# Tasks: Client-Side Config UI

**Input**: Design documents from `/specs/001-client-config-ui/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

---

## Phase 1: Setup (Shared Infrastructure)

- [ ] T001 Create Nuxt.js project structure per plan.md (app.vue, pages/, assets/css/main.css, public/)
- [ ] T002 Initialize TypeScript and Nuxt.js dependencies in package.json
- [ ] T003 [P] Configure linting and formatting tools in package.json and tsconfig.json

---

## Phase 2: Foundational (Blocking Prerequisites)

- [ ] T004 Remove all install and startup scripts except new startup script (install-kiosk.sh, startup-kiosk.sh, family-calendar-kiosk.service)
- [ ] T005 [P] Create base CalendarConfig entity in specs/001-client-config-ui/data-model.md
- [ ] T006 [P] Setup localstorage utility for config persistence in pages/config.vue
- [ ] T007 Configure error handling and logging for config UI in pages/config.vue
- [ ] T008 Setup environment configuration management in nuxt.config.ts

---

## Phase 3: User Story 1 - Configure Calendar & Quote URLs (Priority: P1) 🎯 MVP

- [ ] T009 [P] [US1] Create config page UI with variable number of text boxes and submit button in pages/config.vue
- [ ] T010 [P] [US1] Implement localstorage save/load logic for calendar/quote URLs in pages/config.vue
- [ ] T011 [US1] Add validation for calendar/quote URLs in pages/config.vue
- [ ] T012 [US1] Integrate config UI with main calendar display in pages/index.vue
- [ ] T013 [US1] Add error handling and user feedback for config actions in pages/config.vue

---

## Phase 4: User Story 2 - Kiosk Startup (Priority: P2)

- [ ] T014 [P] [US2] Write startup-kiosk.sh script to launch Chrome in kiosk mode with no cursor (startup-kiosk.sh)
- [ ] T015 [US2] Add script logging and error handling in startup-kiosk.sh
- [ ] T016 [US2] Document script usage and prerequisites in README.md

---

## Phase 5: User Story 3 - Edit Config (Priority: P3)

- [ ] T017 [P] [US3] Add UI for editing/removing calendar/quote URLs in pages/config.vue
- [ ] T018 [US3] Implement update logic for config in localstorage in pages/config.vue
- [ ] T019 [US3] Add user feedback for successful/failed edits in pages/config.vue

---

## Phase N: Polish & Cross-Cutting Concerns

- [ ] T020 [P] Documentation updates in README.md
- [ ] T021 Code cleanup and refactoring across pages/config.vue, startup-kiosk.sh
- [ ] T022 Performance optimization for config UI and script
- [ ] T023 [P] Additional unit/e2e tests in tests/
- [ ] T024 Security hardening for config UI and script
- [ ] T025 Run quickstart.md validation (specs/001-client-config-ui/quickstart.md)

---

## Dependencies & Execution Order

- Setup → Foundational → User Stories (P1, P2, P3) → Polish
- User stories are independently testable and can be implemented in parallel after foundational phase

## Parallel Execution Examples

- T003, T005, T006 can run in parallel (different files)
- T009, T010 can run in parallel (UI and logic)
- T014, T017 can run in parallel (script and UI)

## Implementation Strategy

- MVP: Complete User Story 1 (config page, persistence)
- Incremental: Add kiosk script (User Story 2), then edit config (User Story 3)
- Validate each story independently before proceeding

---

# Summary
- Total tasks: 25
- Tasks per user story: US1 (5), US2 (3), US3 (3)
- Parallel opportunities: Setup, foundational, UI/script, tests
- Independent test criteria: Each story has clear testable outcome
- MVP scope: User Story 1 (config page + persistence)
- Format validation: All tasks follow strict checklist format (checkbox, ID, labels, file paths)
