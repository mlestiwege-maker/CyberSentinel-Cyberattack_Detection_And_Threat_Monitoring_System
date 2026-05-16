# Free hosting guide for CyberSentinel

Yes — this project is hostable on free tiers, with one important caveat:

- **Cloud-friendly:** dashboard, auth, alerts, metrics, Twilio notification delivery, API endpoints
- **Local-only / demo-only:** raw packet sniffing or anything that depends on direct access to local network traffic

The best free stack for this repo is:

- **Backend:** Render (free web service)
- **Frontend:** Firebase Hosting or Vercel (Firebase is usually the easiest for Flutter web)
- **Code:** GitHub
- **Notifications:** Twilio

## 1) What must be true before deploying

Your backend and frontend are now ready for deployment if you:

- set real environment variables on the backend
- point the frontend to the deployed backend URL
- configure CORS to allow the frontend origin
- avoid using localhost URLs in production

The frontend now supports this via:

- `BACKEND_BASE_URL` dart define
- default fallback remains `http://127.0.0.1:8000` for local dev

## 2) Deploy the backend to Render

### Create the service
1. Sign in to Render with GitHub.
2. Create a **New Web Service**.
3. Choose this repository.
4. Set the root directory to `backend`.

### Build and start commands

Use:

```bash
pip install -r requirements.txt
```

Start command:

```bash
python -m uvicorn main:app --host 0.0.0.0 --port $PORT
```

### Add environment variables

Set at least these on Render:

- `ENVIRONMENT=production`
- `SECRET_KEY=<strong-random-secret>`
- `DATABASE_URL=<your database url>`
- `ALLOWED_ORIGINS=["https://your-frontend-domain"]`
- `TWILIO_ACCOUNT_SID=...`
- `TWILIO_AUTH_TOKEN=...`
- `TWILIO_FROM_NUMBER=...`
- `ALERT_SMS_RECIPIENTS=["+your_number"]`
- `ALERT_EMAIL_RECIPIENTS=["you@example.com"]`

If you want a simple free setup for presentation, you can start with SQLite locally and upgrade to a hosted database later.

### Test the backend

After deployment, check:

```bash
GET https://<your-backend>.onrender.com/health
```

Expected:

```json
{"status":"healthy"}
```

## 3) Deploy the Flutter frontend to Firebase Hosting

### Build the web app

Replace the backend URL with your Render app URL:

```bash
flutter build web --dart-define=BACKEND_BASE_URL=https://<your-backend>.onrender.com
```

### Initialize Firebase Hosting

```bash
npm install -g firebase-tools
firebase login
firebase init hosting
```

Choose:

- public directory: `build/web`
- single-page app: `Yes`

Then deploy:

```bash
firebase deploy
```

## 4) Configure CORS on the backend

In Render, make sure `ALLOWED_ORIGINS` includes the deployed frontend URL, for example:

```json
["https://<your-frontend>.web.app"]
```

## 5) Important production notes

- Do **not** commit `backend/.env`.
- Do **not** put real Twilio secrets into the Flutter web build.
- Use the backend for actual automated alerts.
- Keep the Twilio settings UI as a demo/admin setup screen, not as a place for shared organization secrets.

## 6) Best presentation strategy

For demos:

- Use the **local** environment when showing packet capture / local attack simulation.
- Use the **free hosted** environment when showing public access, login, dashboard, alerts, and metrics.

That gives you the strongest possible presentation:

- local demo = deep technical credibility
- cloud demo = professional portfolio value
