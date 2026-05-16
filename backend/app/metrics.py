"""Prometheus metrics for CyberSentinel backend.

Provides counters/histograms to be used across the app. Importing this module
is safe when prometheus_client is available; otherwise no-op fallbacks are used.
"""
from typing import Callable

try:
    from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
except Exception:  # pragma: no cover - fallback when package missing
    Counter = None
    Histogram = None
    generate_latest = None
    CONTENT_TYPE_LATEST = "text/plain; version=0.0.4; charset=utf-8"


def _make_counter(name: str, documentation: str, labelnames=()):
    if Counter is None:
        class _Noop:
            def labels(self, *args, **kwargs):
                return self

            def inc(self, amount=1):
                return None

        return _Noop()
    return Counter(name, documentation, labelnames)


def _make_histogram(name: str, documentation: str, labelnames=()):
    if Histogram is None:
        class _Noop:
            def labels(self, *args, **kwargs):
                return self

            def observe(self, value):
                return None

        return _Noop()
    return Histogram(name, documentation, labelnames)


# Notification counters
notification_email_sent = _make_counter("cybersentinel_notification_email_sent_total", "Total successful email notifications", ("severity",))
notification_email_failed = _make_counter("cybersentinel_notification_email_failed_total", "Total failed email notifications", ("severity",))
notification_sms_sent = _make_counter("cybersentinel_notification_sms_sent_total", "Total successful SMS notifications", ("severity",))
notification_sms_failed = _make_counter("cybersentinel_notification_sms_failed_total", "Total failed SMS notifications", ("severity",))

# HTTP request metrics
http_request_duration_seconds = _make_histogram("cybersentinel_http_request_duration_seconds", "Histogram of HTTP request durations in seconds", ("method", "endpoint"))


def metrics_response():
    if generate_latest is None:
        return (b"", "text/plain")
    return generate_latest(), CONTENT_TYPE_LATEST
