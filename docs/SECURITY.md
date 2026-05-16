# Security Notes and Deployment Baseline

## Secrets management

- Do not commit `backend/.env`.
- Use `backend/.env.example` as template only.
- In production, inject secrets via secret manager / platform secret store.

Required sensitive values:
- `SECRET_KEY`
- `DEFAULT_ADMIN_PASSWORD`
- `SMTP_PASSWORD`
- `TWILIO_AUTH_TOKEN`

## Hardening currently implemented

- Strong password validation for registration.
- Retry/backoff for email/SMS dispatch.
- Security response headers on API responses.
- Production startup guard against insecure defaults.
- CI dependency scan via `pip-audit`.
- Dependabot weekly updates for Python dependencies and GitHub Actions.

## Recommended next hardening steps

1. Enforce HTTPS/TLS at ingress with HSTS (reverse proxy / gateway).
2. Add rate limiting on login and sensitive endpoints.
3. Implement account lockout / progressive delay on repeated failed logins.
4. Add signed audit logs for auth and admin actions.
5. Move from shared default admin seed to bootstrap one-time setup flow.
