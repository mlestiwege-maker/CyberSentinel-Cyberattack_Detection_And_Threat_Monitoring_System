# CyberSentinel Backend API

FastAPI backend for real-time cyberattack detection and threat monitoring.

## Features

- **Authentication**: User registration, login, JWT tokens
- **Threat Detection**: ML-powered threat detection with features for DDOS, Ransomware, Brute Force, Port Scan
- **Alerts**: Real-time alert management
- **Dashboard**: Summary statistics for threats, alerts, incidents
- **Incidents**: Incident management with status tracking
- **Twilio SMS**: SMS alert sending capability
- **Voice Assistant**: Voice command processing
- **Users & Roles**: User management with role-based permissions
- **Reports**: Security report generation and export

## Requirements

- Python 3.9+
- SQLite (or PostgreSQL for production)

## Installation

```bash
cd backend
pip install -r requirements.txt
```

## Running the Backend

### Development Mode

```bash
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Production Mode

```bash
cd backend
gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app --bind 0.0.0.0:8000
```

## API Documentation

Once running, access:
- Swagger UI: http://localhost:8000/api/docs
- OpenAPI JSON: http://localhost:8000/api/openapi.json

## Environment Variables

Create a `.env` file in the backend directory:

```env
API_TITLE=CyberSentinel API
API_VERSION=1.0.0
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

## Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login and get JWT token
- `GET /api/v1/auth/me` - Get current user info

### Threats
- `POST /api/v1/threats/detect` - Detect threat from network features
- `GET /api/v1/threats` - List threats
- `PATCH /api/v1/threats/{id}/resolve` - Resolve a threat

### Alerts
- `GET /api/v1/alerts` - List alerts
- `PATCH /api/v1/alerts/{id}` - Update alert (mark as read)
- `GET /api/v1/alerts/stats/summary` - Get alert statistics

### Dashboard
- `GET /api/v1/dashboard/summary` - Get dashboard summary statistics

### Incidents
- `GET /api/v1/incidents` - List incidents
- `POST /api/v1/incidents` - Create new incident
- `GET /api/v1/incidents/{id}` - Get specific incident
- `PATCH /api/v1/incidents/{id}` - Update incident status
- `GET /api/v1/incidents/stats/summary` - Get incident statistics

### Twilio SMS
- `POST /api/v1/twilio/send` - Send SMS
- `GET /api/v1/twilio/messages` - List SMS logs
- `POST /api/v1/twilio/messages/bulk` - Send bulk SMS

### Voice Assistant
- `POST /api/v1/voice/command` - Process voice command
- `GET /api/v1/voice/history` - Get command history

### Users
- `GET /api/v1/users` - List users
- `GET /api/v1/users/roles` - Get available roles and permissions
- `GET /api/v1/users/team` - Get team member structure

### Reports
- `GET /api/v1/reports` - List available reports
- `POST /api/v1/reports/export` - Export a report
- `GET /api/v1/reports/export/all` - Export all reports

## Connecting with Frontend

The frontend expects the backend at `http://127.0.0.1:8000`.

1. Start the backend:
   ```bash
   cd backend
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

2. Run the Flutter frontend:
   ```bash
   cd ..
   flutter run -d chrome
   ```

3. The frontend will automatically connect to the backend API.

## Database

The backend uses SQLite by default. The database is automatically initialized on startup.

For production, modify `app/core/config.py` to use PostgreSQL:

```python
SQLALCHEMY_DATABASE_URL = "postgresql://user:password@localhost/dbname"
```