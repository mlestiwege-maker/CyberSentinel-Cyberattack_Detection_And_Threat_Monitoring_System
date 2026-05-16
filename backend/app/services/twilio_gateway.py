"""Direct Twilio REST API helper used when the Twilio SDK is unavailable."""

from __future__ import annotations

from base64 import b64encode
from dataclasses import dataclass
from typing import Any

import requests
from app.utils.retry import retry_call


@dataclass
class TwilioSendResult:
    success: bool
    sid: str | None = None
    status: str | None = None
    raw: Any = None


def send_sms(*, account_sid: str, auth_token: str, from_number: str, to_number: str, message: str) -> TwilioSendResult:
    """Send an SMS directly through Twilio's Messages REST endpoint."""
    if not account_sid or not auth_token or not from_number or not to_number:
        raise ValueError("Twilio credentials and destination number are required")

    url = f"https://api.twilio.com/2010-04-01/Accounts/{account_sid}/Messages.json"
    credentials = b64encode(f"{account_sid}:{auth_token}".encode("utf-8")).decode("ascii")

    response = requests.post(
        url,
        headers={
            "Authorization": f"Basic {credentials}",
            "Content-Type": "application/x-www-form-urlencoded",
        },
        data={
            "From": from_number,
            "To": to_number,
            "Body": message,
        },
        timeout=15,
    )

    if 200 <= response.status_code < 300:
        payload = response.json() if response.content else {}
        return TwilioSendResult(
            success=True,
            sid=payload.get("sid"),
            status=payload.get("status"),
            raw=payload,
        )

    raise RuntimeError(f"Twilio send failed ({response.status_code}): {response.text.strip()}")


def send_sms_with_retry(*, account_sid: str, auth_token: str, from_number: str, to_number: str, message: str, tries: int = 3) -> TwilioSendResult:
    """Send SMS with retries/backoff. Returns TwilioSendResult on success or raises the last error."""
    def _call():
        return send_sms(account_sid=account_sid, auth_token=auth_token, from_number=from_number, to_number=to_number, message=message)

    return retry_call(_call, exceptions=(RuntimeError, requests.RequestException), tries=tries)