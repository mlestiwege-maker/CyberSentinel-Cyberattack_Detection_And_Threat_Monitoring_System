# CyberSentinel Frontend

CyberSentinel is a Flutter-based cybersecurity operations dashboard for threat visibility, incident response, team coordination, and alerting.

The backend now automatically creates alerts when threats are detected and dispatches SMS/email notifications in the background so detections are not slowed down by delivery failures.

The notification payload now uses a detailed CyberSentinel security alert template that includes the title, severity, timestamp, confidence, alert ID, attack type, source IP, and description.

## Project repository

`https://github.com/mlestiwege-maker/CyberSentinel-Cyberattack_Detection_And_Threat_Monitoring_System`

## Core features

- Live dashboard with threat stats and analytics cards
- Threat table and attack-map style monitoring views
- Incident and monitoring screens
- Defensive terminal simulation tools
- Twilio SMS sending workflow (via API)
- Email alert workflow (opens mail client with prefilled recipients)
- Group email member management in settings
- Users & roles page with project team ownership mapping
- Reports page with contributor snapshot and exports list
- Voice assistant panel (UI workflow)

## Team and workstream ownership

- **Project Planning** — Tadiwa Sharara
- **Backend Development** — Bunu Anesu
- **Network Monitoring** — Madamu Creig
- **Machine Learning** — Davison Karamenti
- **Threat Detection** — Dzimbanhete Bhunu
- **Frontend Development** — Lestiwege Mufutumari
- **Admin Features** — Shared team
- **Notifications** — Shared team
- **Testing** — Tinashe Matyamaenza
- **Documentation** — Agatha Katiyo

## Tech stack

- Flutter / Dart
- `http` for backend and Twilio requests
- `url_launcher` for email launch (`mailto:`)

## Important app flows

### 1) SMS alerts

1. Open **Settings** → **Twilio Integration**.
2. Add Twilio `Account SID`, `Auth Token`, and `From Number`.
3. Open **SMS / Twilio** screen.
4. Enter destination number and message.
5. Click **Send SMS**.

When the backend detects a threat, it also sends the alert to the recipients configured in `backend/.env`:

- `ALERT_SMS_RECIPIENTS` for mobile numbers
- `ALERT_EMAIL_RECIPIENTS` for email addresses

If `USE_MOCK_TWILIO=True`, SMS messages are written to `~/.cybersentinel/mock_sms.log`. If SMTP is not configured, email targets are written to `~/.cybersentinel/mock_email.log` so the system still records the alert path during local testing.

The backend alert template is designed to match the production-style messages previously sent to your phone/email, for example:

- `CyberSentinel Security Alert`
- `Title: Security Alert: Brute Force`
- `Severity: HIGH`
- `Message: Threat detected from <source IP> ...`
- `Details: Alert_Id, Attack_Type, Source_Ip, Confidence, Description`

SMS notifications now use a multi-line phone-friendly format with the same threat details, including timestamp, alert ID, attack type, and description.

### 2) Email alerts to group members

1. Open **Settings** → **Group Email Members**.
2. Add/remove member emails.
3. Open **SMS / Twilio** screen.
4. Click the email button to launch your default mail client for all recipients.

If no group email is added, the default fallback recipient is `mlestiwege@gmail.com`.

## Real-time alert delivery

The monitoring flow is automatic:

1. The ML service scores traffic.
2. Threats are stored in the database.
3. An alert record is created for the dashboard.
4. SMS and email notifications are queued in the background.

This keeps the threat detection path responsive even if Twilio or SMTP is slow or unavailable.

## Project structure (high-level)

`lib/`
- `core/` theme and constants
- `layout/` shell, sidebar, top bar
- `features/dashboard/` dashboard and widgets
- `features/monitoring/` monitor, attack map, defensive console
- `features/incidents/` incidents view
- `features/reports/` reports and team snapshot
- `features/settings/` Twilio + group-email settings
- `features/users/` users, roles, and team tasks
- `features/sms/` Twilio/SMS screen
- `features/voice/` voice assistant screen
- `services/` API service, Twilio service, runtime app config
- `models/` alert data model

## Run locally

### Prerequisites

- Flutter SDK (3.x)
- Dart SDK (3.x)

### Commands

```bash
flutter pub get
flutter run -d linux
```

You can also run on web or another supported device target.

## Quality checks

- Analyzer checks are currently clean in this workspace.
- Latest Linux run completed successfully in the current session.

## Notes

- Twilio credentials are currently stored in backend configuration for local testing.
- For production, move secrets to secure storage / backend-managed configuration.
- Use a real SMTP app password and a verified Twilio recipient to enable live delivery.
- If you are using a Twilio trial account, the destination number must be verified in Twilio before live SMS delivery can succeed.

## License

Part of a university group cybersecurity project.
