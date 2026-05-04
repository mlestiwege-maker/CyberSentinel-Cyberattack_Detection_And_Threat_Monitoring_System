# CyberSentinel Frontend

CyberSentinel is a Flutter-based cybersecurity operations dashboard for threat visibility, incident response, team coordination, and alerting.

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

### 2) Email alerts to group members

1. Open **Settings** → **Group Email Members**.
2. Add/remove member emails.
3. Open **SMS / Twilio** screen.
4. Click the email button to launch your default mail client for all recipients.

If no group email is added, the default fallback recipient is `mlestiwege@gmail.com`.

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

- Twilio credentials are currently stored in-memory for this UI prototype session.
- For production, move secrets to secure storage / backend-managed configuration.

## License

Part of a university group cybersecurity project.
