# Changelog

All notable updates to this project are documented here.

## 2026-05-04

### Added
- Team ownership integration in `Users & Roles` for project workstreams.
- Group email member management in `Settings`.
- Email launch workflow for alerts from Twilio panel (`mailto:` via `url_launcher`).
- Twilio SMS service integration with status updates (`QUEUED`, `SENT`, `FAILED`).
- New dashboard widgets:
  - `IncidentsOverview`
  - `TopAttackTypes`
  - `VoiceAssistantCard`
- New feature screens:
  - `SMS / Twilio`
  - `Users & Roles`
  - `Voice Assistant`

### Changed
- Main dashboard layout and top navigation polish.
- Sidebar navigation and section organization.
- Reports screen to include a team contributors snapshot.
- `StatCard` composition fixed to avoid invalid nested `Expanded` usage.

### Fixed
- Multiple dashboard layout overflow and parent-data issues.
- Analyzer errors in updated screens and widgets.
- Runtime stability issues encountered during iterative Linux runs.
