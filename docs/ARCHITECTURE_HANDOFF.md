# CyberSentinel Architecture Handoff

## 1) System overview

CyberSentinel is a Flutter-based frontend for cyberattack detection and threat monitoring workflows.

Current implementation focus:
- Security operations dashboard UX
- Incident visibility
- Notification workflows (SMS + email launch)
- Team ownership visibility for workstreams

## 2) Frontend architecture

### App shell
- `lib/main.dart` boots the app and theme.
- `lib/layout/main_layout.dart` provides the main container:
  - top administrator bar
  - sidebar navigation
  - per-feature content area

### Design system
- `lib/core/theme.dart` defines dark cybersecurity palette and reusable colors.

### Feature modules
- `lib/features/dashboard/`:
  - live metrics, threat feed, attack map, incidents overview, top attack types, system stats, terminal, voice, Twilio panel
- `lib/features/monitoring/`:
  - monitor, defensive console, and attack-map views
- `lib/features/incidents/`:
  - incident tracking UI
- `lib/features/reports/`:
  - report cards and contributors summary
- `lib/features/users/`:
  - users, roles, and project workstream ownership
- `lib/features/sms/`:
  - Twilio/SMS and email notification screen
- `lib/features/settings/`:
  - Twilio credentials and group email member management
- `lib/features/voice/`:
  - assistant screen wrapper

### Services and state
- `lib/services/api_service.dart`:
  - backend GET calls for alerts/threats/incidents
- `lib/services/twilio_service.dart`:
  - Twilio REST API POST for SMS
- `lib/services/app_config.dart`:
  - in-memory runtime app config for Twilio credentials and group emails

### Data model
- `lib/models/alert_model.dart`:
  - typed alert mapping from API JSON

## 3) Notification architecture

### SMS path
1. User enters Twilio credentials in Settings.
2. Credentials stored in `AppConfig` (runtime memory).
3. User sends SMS from Twilio panel.
4. `TwilioService.sendSms(...)` calls Twilio endpoint.
5. UI updates message status (`QUEUED` -> `SENT` or `FAILED`).

### Email path
1. Group members are managed in Settings.
2. Email button in Twilio panel constructs `mailto:` recipients.
3. `url_launcher` opens default mail client with subject/body.
4. Fallback recipient is `mlestiwege@gmail.com` if no group emails are added.

## 4) Team workstream integration

Embedded in `Users & Roles` and summarized in `Reports`:
- Project Planning — Tadiwa Sharara
- Backend Development — Bunu Anesu
- Network Monitoring — Madamu Creig
- Machine Learning — Davison Karamenti
- Threat Detection — Dzimbanhete Bhunu
- Frontend Development — Lestiwege Mufutumari
- Admin Features — Shared Team
- Notifications — Shared Team
- Testing — Tinashe Matyamaenza
- Documentation — Agatha Katiyo

## 5) Known prototype constraints

- Twilio credentials are currently stored in-memory only.
- Email sending is client-mail-launch based (`mailto`), not SMTP/backend email dispatch.
- Several panels still use mock data where backend endpoints are not yet wired.

## 6) Recommended next engineering steps

1. Move secrets and notification execution to backend-managed services.
2. Persist non-secret preferences with local storage.
3. Add role-based access controls on sensitive screens.
4. Wire real-time stream updates (WebSocket or SSE).
5. Add widget/integration tests for notification and settings flows.
