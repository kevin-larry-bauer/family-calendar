
# Feature Specification: Client-Side Config UI

**Feature Branch**: `001-client-config-ui`  
**Created**: 2026-02-18  
**Status**: Draft  
**Input**: User description: "Update the application to be client-side only. Instead of pulling google calendar URLs from a config file, create a page called 'config' that allows adding them through a UI with a variable number of text boxes and a submit button. When the user clicks the submit button, store the calendar URLs in permanent localstorage. Do the same for the url of the quote file. Remove any install and startup scripts, and replace them with a single startup script that opens chrome in kiosk mode with no visible cursor."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Configure Calendar & Quote URLs (Priority: P1)


User visits the "config" page, adds one or more Google Calendar feeds, each with a label, a color, and a URL, plus a quote file URL via text boxes, clicks submit, and sees the configuration persist after reload.

**Why this priority**: This is the core value—enables dynamic calendar setup without editing files.

**Independent Test**: Can be fully tested by adding URLs, submitting, reloading, and verifying persistence.

**Acceptance Scenarios**:

1. **Given** no calendars are set, **When** user adds one or more calendars (label, color, URL) and submits, **Then** calendars and quote file are stored and loaded on next visit.
2. **Given** calendars/quote file are already set, **When** user edits and submits, **Then** changes (including label, color, or URL) are reflected and persist.

---

### User Story 2 - Kiosk Startup (Priority: P2)

User launches the app via the new startup script, which opens Chrome in kiosk mode with no visible cursor.

**Why this priority**: Ensures seamless display for dedicated devices.

**Independent Test**: Can be fully tested by running the script and observing Chrome behavior.

**Acceptance Scenarios**:

1. **Given** the script is run, **When** Chrome launches, **Then** app is fullscreen, no cursor is visible.

---

### User Story 3 - Edit Config (Priority: P3)

User returns to config page, adds/removes calendars (label, color, URL) or changes quote file URL, submits, and sees changes reflected.

**Why this priority**: Allows ongoing customization and maintenance.

**Independent Test**: Can be fully tested by editing config and verifying updates.

**Acceptance Scenarios**:

1. **Given** existing config, **When** user edits and submits (including label, color, or URL), **Then** new config is stored and loaded.

---

### Edge Cases

- What happens if user submits empty URLs?
- How does system handle unavailable localstorage?
- What if Chrome fails to launch in kiosk mode?

## Requirements *(mandatory)*

### Functional Requirements

-- **FR-001**: System MUST provide a "config" page with UI for a variable number of calendars, each with a label, color, and URL, and a quote file URL.
-- **FR-002**: System MUST store calendars (label, color, URL) and quote file URL in permanent localstorage on submit.
-- **FR-003**: System MUST load calendars (label, color, URL) and quote file URL from localstorage on page visit.
-- **FR-004**: System MUST allow editing/removing calendars (label, color, URL) and quote file URL via UI.
- **FR-005**: System MUST remove all install/startup scripts except new startup script.
- **FR-006**: System MUST provide a startup script that launches Chrome in kiosk mode with no visible cursor.

### Key Entities

- **CalendarConfig**: Represents calendars (array of { label: string, color: string, url: string }) and quoteUrl (string).
- **Localstorage**: Stores CalendarConfig for persistence.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can add/edit calendars (label, color, URL) and quote file URL and see them persist after reload.
- **SC-002**: Chrome launches in kiosk mode, no visible cursor.
- **SC-003**: No install/startup scripts remain except new startup script.
- **SC-004**: 95% of users successfully configure calendars without support.

## Assumptions

- Chrome is installed and supports kiosk mode.
- Localstorage is available in browser.
- Users can access config page.
