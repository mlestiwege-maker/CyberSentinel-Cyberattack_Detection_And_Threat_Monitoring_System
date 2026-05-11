import requests
from config import config, log_to_file
from typing import Dict, Any, Optional


# CyberSentinel backend expects events at this sub-path
_INGEST_PATH = '/api/v1/network-monitor/ingest'


def send_event(event: Dict[str, Any], alert: Optional[str] = None, severity: str = 'low'):
    """
    Forward a normalised event (and optional alert) to the CyberSentinel
    backend, or fall back to local file logging if the backend is unreachable.

    Args:
        event:    Normalised event dict from parsers.normalize_event()
        alert:    Alert string from LocalAnalyzer, or None
        severity: 'low' | 'medium' | 'high' | 'critical'
    """
    payload = event.copy()
    if alert:
        payload['alert']    = alert
        payload['severity'] = severity
    else:
        payload['severity'] = 'low'

    if config.BACKEND_URL:
        _send_to_backend(payload)
    else:
        _log_locally(payload)


def _send_to_backend(payload: Dict[str, Any]):
    url = config.BACKEND_URL.rstrip('/') + _INGEST_PATH
    try:
        response = requests.post(url, json=payload, timeout=5)
        response.raise_for_status()
        ts = payload.get('timestamp', '')[:19]
        print(f"✅ Sent to backend: {ts}")
    except Exception as e:
        print(f"❌ Backend unreachable ({e}), logging locally instead")
        _log_locally(payload)


def _log_locally(payload: Dict[str, Any]):
    log_to_file(config.EVENTS_LOG, payload)

    if payload.get('alert'):
        log_to_file(config.ALERTS_LOG, payload)
        print(f"🚨 ALERT [{payload['severity'].upper()}]: {payload['alert']} "
              f"| {payload.get('src_ip', 'N/A')} "
              f"| {payload.get('timestamp', '')[:19]}")
    else:
        print(f"📊 Logged: {payload.get('timestamp', '')[:19]}")
