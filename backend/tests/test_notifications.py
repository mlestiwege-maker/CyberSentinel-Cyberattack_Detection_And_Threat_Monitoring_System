import json
import os
from pathlib import Path

import pytest

from app.services.twilio_gateway import send_sms_with_retry, TwilioSendResult


class DummyResp:
    def __init__(self, status_code, payload=None, text=""):
        self.status_code = status_code
        self._payload = payload or {}
        self.text = text
        self.content = json.dumps(self._payload).encode("utf-8") if payload else b""

    def json(self):
        return self._payload


def test_send_sms_with_retry_success(monkeypatch):
    calls = {"count": 0}

    def fake_post(url, headers, data, timeout):
        calls["count"] += 1
        # fail the first call, succeed on second
        if calls["count"] == 1:
            return DummyResp(500, payload={"message": "server error"}, text="server error")
        return DummyResp(201, payload={"sid": "SM12345", "status": "queued"})

    monkeypatch.setattr("requests.post", fake_post)

    result = send_sms_with_retry(
        account_sid="AC_TEST",
        auth_token="AUTH",
        from_number="+10000000000",
        to_number="+15551234567",
        message="hello",
        tries=3,
    )

    assert isinstance(result, TwilioSendResult)
    assert result.success is True
    assert result.sid == "SM12345"


def test_dispatch_notifications_fallback(tmp_path, monkeypatch):
    # Ensure logs are written to temp home
    monkeypatch.setenv("HOME", str(tmp_path))

    # Ensure recipients exist so code paths execute
    import app.services.threat_service as ts
    monkeypatch.setattr(ts.settings, "ALERT_SMS_RECIPIENTS", ["+15551234567"], raising=False)
    monkeypatch.setattr(ts.settings, "ALERT_EMAIL_RECIPIENTS", ["alert@example.com"], raising=False)
    # Ensure we exercise the Twilio failure code path (not the mock path)
    monkeypatch.setattr(ts.settings, "USE_MOCK_TWILIO", False, raising=False)

    # Make email send fail
    class FakeEmailService:
        def send_email(self, to_emails, subject, body, html_body=None):
            return False

    monkeypatch.setattr("app.services.threat_service.EmailService", FakeEmailService)

    # Make Twilio send raise
    def fake_send(*, account_sid, auth_token, from_number, to_number, message, tries=3):
        raise RuntimeError("twilio down")

    # patch the reference used by threat_service (it imports send_sms_with_retry)
    monkeypatch.setattr("app.services.threat_service.send_sms_with_retry", fake_send)

    # Call _dispatch_notifications directly
    from app.services.threat_service import _dispatch_notifications

    _dispatch_notifications(
        alert_message="alert",
        sms_message="sms",
        threat_type="ddos",
        severity="critical",
        source_ip="1.2.3.4",
        description="desc",
        html_body="<b>html</b>",
    )

    sms_log = tmp_path / ".cybersentinel" / "mock_sms.log"
    email_log = tmp_path / ".cybersentinel" / "mock_email.log"

    assert sms_log.exists(), "SMS fallback log should exist"
    assert email_log.exists(), "Email fallback log should exist"

    sms_entry = json.loads(sms_log.read_text().strip().splitlines()[-1])
    email_entry = json.loads(email_log.read_text().strip().splitlines()[-1])

    assert sms_entry.get("fallback") == "twilio-failed"
    assert "to" in email_entry
