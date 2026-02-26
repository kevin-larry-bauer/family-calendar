# Data Model: Client-Side Config UI

**Feature**: [specs/001-client-config-ui/spec.md](specs/001-client-config-ui/spec.md)
**Plan**: [specs/001-client-config-ui/plan.md](specs/001-client-config-ui/plan.md)
**Date**: 2026-02-18

## Entities

### CalendarConfig
- calendars: Array<Calendar>
- quoteUrl: string

### Calendar
- label: string
- color: string
- url: string

## Relationships
- CalendarConfig is stored in browser localstorage

## Validation Rules
- calendars: each calendar must have a non-empty label, a valid color string, and a valid Google Calendar URL
- quoteUrl: must be valid URL, non-empty

## State Transitions
- On submit: CalendarConfig (with calendars: [{label, color, url}], quoteUrl) is written to localstorage
- On page load: CalendarConfig is read from localstorage
- On edit: CalendarConfig is updated and persisted
