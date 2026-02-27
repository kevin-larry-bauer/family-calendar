# Phase 0 Research: Client-Side Config UI

**Feature**: [specs/001-client-config-ui/spec.md](specs/001-client-config-ui/spec.md)
**Plan**: [specs/001-client-config-ui/plan.md](specs/001-client-config-ui/plan.md)
**Date**: 2026-02-18

## Unknowns & Clarifications

- Testing: What is the recommended unit/e2e test framework for Nuxt 3 config UI?
- Chrome kiosk: What is the best practice for launching Chrome in kiosk mode with no cursor on Raspberry Pi?

## Research Tasks

1. Research Nuxt 3 testing frameworks for config UI (unit/e2e)
2. Research Chrome kiosk mode startup script (no cursor) for Raspberry Pi

## Decisions & Rationale

- Decision: Use Nuxt.js and Vue 3 for config UI
  - Rationale: Matches existing stack, supports client-side localstorage
  - Alternatives: React, Svelte (rejected for compatibility)

- Decision: Store calendar/quote URLs in browser localstorage
  - Rationale: Permanent, client-side persistence
  - Alternatives: IndexedDB, cookies (rejected for simplicity)

- Decision: Remove all install/startup scripts except new startup script
  - Rationale: Simplifies deployment, aligns with client-side only

## Alternatives Considered

- IndexedDB for config storage (rejected: overkill for simple key-value)
- Multiple config pages (rejected: single config page is sufficient)
- Server-side config (rejected: violates client-side only constraint)

## Next Steps

- Resolve testing framework and Chrome kiosk script best practices
- Update plan.md with research findings
