# CyberSentinel Alert Configuration Guide

This guide explains how to configure SMS and Email alerts in CyberSentinel.

## SMS Alerts (Twilio)

### Prerequisites
- Twilio account at https://www.twilio.com
- Twilio Account SID and Auth Token
- A Twilio phone number (from number)
- Your phone number (to number)

### Configuration Steps

1. **In the App (Frontend)**:
   - Open CyberSentinel
   - Go to **Settings** → **Twilio Integration**
   - Enter your:
     - Twilio Account SID
     - Twilio Auth Token
     - Twilio From Number (the SMS sender number)
   - Click **Save**

2. **Sending SMS**:
   - Open **SMS / Twilio** tab
   - Enter the destination phone number
   - Enter your alert message
   - Click **Send SMS**
   - Status will update to QUEUED → SENT or FAILED

### Twilio Setup Example (Gmail-style)

1. Create Twilio account at https://console.twilio.com
2. Get your credentials:
   - Account SID: `ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
   - Auth Token: `your_auth_token_here`
   - From Number: `+1234567890` (your Twilio phone)
3. Add destination numbers you want to send to
4. Paste into app Settings

---

## Email Alerts

### Prerequisites (Gmail + App Password)
- Gmail account
- Gmail App Password (2FA must be enabled)
  - Generate at: https://myaccount.google.com/apppasswords
- Group email recipients (optional)

### Configuration Steps

1. **In the Backend (.env)**:
   - Open `backend/.env`
   - Update SMTP settings:
     ```
     SMTP_SERVER=smtp.gmail.com
     SMTP_PORT=587
     SMTP_USERNAME=your-email@gmail.com
     SMTP_PASSWORD=xxxx xxxx xxxx xxxx (app-specific password)
     SMTP_USE_TLS=True
     ```
   - Restart backend: `python3 backend/main.py`

2. **In the App (Frontend)**:
   - Open CyberSentinel
   - Go to **Settings** → **Group Email Members**
   - Add email addresses for alert recipients (e.g., team members)
   - Click **Add**

3. **Sending Emails**:
   - Open **SMS / Twilio** tab
   - Enter your alert message
   - Click **Email (N)** button where N = number of recipients
   - Email will be sent via backend SMTP or fallback to mail client if backend is down

### Gmail App Password Setup

1. Enable 2-Step Verification:
   - Go to https://myaccount.google.com/security
   - Enable "2-Step Verification"

2. Generate App Password:
   - Go to https://myaccount.google.com/apppasswords
   - Select "Mail" and "Linux" (or your OS)
   - Google generates a 16-character password
   - Copy and paste into `backend/.env` as `SMTP_PASSWORD`
   - Note: Spaces are normal, you can include all 16 chars with spaces

3. Example `.env`:
   ```
   SMTP_USERNAME=john.doe@gmail.com
   SMTP_PASSWORD=abcd efgh ijkl mnop
   ```

### Testing Email Configuration

1. Start the backend:
   ```bash
   cd backend
   python3 main.py
   ```

2. Test email endpoint (via API or frontend):
   - Open **Settings** in the app
   - Click **Test Email** button
   - Check the recipient inbox for test email

---

## Troubleshooting

### SMS Not Sending
- [ ] Twilio credentials are correct in **Settings**
- [ ] Account has sufficient balance
- [ ] Phone number format is valid (e.g., +263789728505)
- [ ] Twilio number is not rate-limited
- [ ] Check browser console for error messages

### Emails Not Sending
- [ ] SMTP credentials are correct in `backend/.env`
- [ ] Backend has restarted after `.env` changes
- [ ] Gmail account has 2FA enabled
- [ ] Gmail App Password is used (not regular password)
- [ ] Recipient email addresses are valid
- [ ] Check backend logs for SMTP errors

### Connection Issues
- [ ] Backend is running on http://127.0.0.1:8000
- [ ] Frontend can reach backend (check browser Network tab)
- [ ] Firewall/VPN not blocking SMTP port 587

---

## Example Alert Scenarios

### Scenario 1: High-Risk Threat Detected
```
Phone: +263789728505
Message: 🚨 HIGH PRIORITY: Brute Force attack detected from 192.168.1.45. 
         Check dashboard immediately.
Email: Security team receives formatted alert with threat details
```

### Scenario 2: Incident Resolution
```
Phone: +263789728505
Message: ✓ Incident #INC-2024-001 has been resolved. 
         Forensics report available in dashboard.
Email: Stakeholders notified of resolution
```

---

## Backend Email Endpoints

Once SMTP is configured, these endpoints are available:

### 1. Send Email Alert
```bash
POST /api/v1/notifications/email/send
Content-Type: application/json
Authorization: Bearer {token}

{
  "recipients": ["user1@example.com", "user2@example.com"],
  "subject": "CyberSentinel Alert",
  "message": "A security threat has been detected",
  "threat_type": "Brute Force",
  "threat_severity": "HIGH",
  "threat_source": "192.168.1.45"
}
```

### 2. Test Email Configuration
```bash
POST /api/v1/notifications/email/test
Content-Type: application/json
Authorization: Bearer {token}

{
  "test_recipient": "test@example.com"
}
```

### 3. Get Email Status
```bash
GET /api/v1/notifications/email/status
Authorization: Bearer {token}

Response:
{
  "configured": true,
  "smtp_server": "smtp.gmail.com",
  "smtp_port": 587,
  "sender_email": "your-email@gmail.com"
}
```

---

## Security Notes

- **Never commit .env files** with real credentials to version control
- Use environment variables or secrets management in production
- Keep Twilio Auth Tokens and Gmail passwords secure
- Rotate credentials regularly
- Use restricted IAM roles for production deployments
- For production, consider using AWS SES, SendGrid, or similar managed services

---

## Support

For issues or questions:
1. Check the backend logs: `tail -f backend/main.py` output
2. Verify .env configuration is correct
3. Test endpoints manually with curl
4. Check Twilio/Gmail dashboards for account status
