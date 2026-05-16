# CyberSentinel Operations Runbook

This runbook provides day-2 operations guidance for backend services, alert delivery, and incident handling.

## 1. Service health checks

### API health
- Endpoint: `GET /health`
- Expected: `{"status":"healthy"}`

### Metrics endpoint
- Endpoint: `GET /metrics`
- Expected: Prometheus text exposition with counters/histograms.

Key metrics:
- `cybersentinel_notification_email_sent_total`
- `cybersentinel_notification_email_failed_total`
- `cybersentinel_notification_sms_sent_total`
- `cybersentinel_notification_sms_failed_total`
- `cybersentinel_http_request_duration_seconds`

## 2. Alerting delivery triage

When threat notifications are not arriving:

1. Check API logs for `Email dispatch failed` and `Twilio send failed` entries.
2. Validate environment variables in runtime:
   - `SMTP_SERVER`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_PORT`
   - `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_FROM_NUMBER`
   - `ALERT_SMS_RECIPIENTS`, `ALERT_EMAIL_RECIPIENTS`
3. For local/trial mode, inspect fallback logs:
   - `~/.cybersentinel/mock_email.log`
   - `~/.cybersentinel/mock_sms.log`
4. Confirm Twilio number restrictions (trial accounts send only to verified recipients).

## 3. Authentication and user management

### Password policy
User passwords are validated at registration with:
- Minimum length (default: 10)
- At least one uppercase letter
- At least one lowercase letter
- At least one digit
- At least one special character

Policy settings:
- `MIN_PASSWORD_LENGTH`
- `REQUIRE_STRONG_PASSWORD`

## 4. Secure startup checks

On startup, the backend evaluates insecure defaults (e.g. default `SECRET_KEY`, weak default admin password).

- In `ENVIRONMENT=production` with `ENFORCE_STRICT_SECURITY_IN_PROD=True`, startup is refused if insecure defaults are detected.
- In non-production, warnings are emitted instead (for developer awareness).

## 5. Incident response playbook (P1)

1. **Detect**: Spike in `*_failed_total` metrics or customer-reported missing alerts.
2. **Contain**: Switch to safe local fallback (`USE_MOCK_TWILIO=True`) if Twilio outage affects stability.
3. **Mitigate**:
   - Rotate SMTP/Twilio credentials if compromise suspected.
   - Confirm recipient lists and provider account status.
4. **Recover**:
   - Validate `test` notification endpoints.
   - Verify metrics returning to baseline.
5. **Postmortem**:
   - Capture timeline, root cause, impact, and permanent fix tasks.

## 6. Backup and rollback

### Rollback backend image
- Deploy previous known-good image tag from GHCR.

### Rollback code
- Revert the latest release commit on `release/all-updates-20260515` and redeploy.

## 7. Routine maintenance checklist

- [ ] Review CI test runs daily.
- [ ] Review dependency scan output (`pip-audit`) weekly.
- [ ] Merge Dependabot PRs after tests pass.
- [ ] Rotate credentials periodically.
- [ ] Verify `ALERT_*_RECIPIENTS` configuration after roster changes.
