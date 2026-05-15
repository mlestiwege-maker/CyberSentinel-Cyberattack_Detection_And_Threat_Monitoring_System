from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache
from ipaddress import ip_address
from typing import Any
from urllib.error import URLError, HTTPError
from urllib.request import Request, urlopen
import json


@dataclass(frozen=True)
class GeoIPResult:
    ip: str
    city: str
    country: str
    region: str
    latitude: float
    longitude: float
    source: str

    @property
    def location(self) -> str:
        parts = [part for part in [self.city, self.country] if part]
        return ", ".join(parts) if parts else "Unknown"

    def to_dict(self) -> dict[str, Any]:
        return {
            "ip": self.ip,
            "city": self.city,
            "country": self.country,
            "region": self.region,
            "lat": self.latitude,
            "lng": self.longitude,
            "location": self.location,
            "source": self.source,
        }


def _is_private_ip(ip: str) -> bool:
    try:
        return ip_address(ip).is_private
    except Exception:
        return False


def _fallback_geo(ip: str) -> GeoIPResult:
    if _is_private_ip(ip):
        return GeoIPResult(
            ip=ip,
            city="Harare",
            country="Zimbabwe",
            region="Harare Province",
            latitude=-17.8252,
            longitude=31.0335,
            source="fallback-private",
        )

    # Stable, deterministic pseudo-location for public IPs when the lookup service is unavailable.
    h = sum(ord(ch) for ch in ip)
    latitude = ((h % 140) - 70) + ((h % 100) / 100.0)
    longitude = (((h * 37) % 360) - 180) + (((h * 13) % 100) / 100.0)
    return GeoIPResult(
        ip=ip,
        city="Unknown",
        country="Unknown",
        region="Unknown",
        latitude=float(latitude),
        longitude=float(longitude),
        source="fallback-deterministic",
    )


@lru_cache(maxsize=512)
def geolocate_ip(ip: str) -> GeoIPResult:
    """Resolve an IP address to geo coordinates using ip-api.com, with a safe fallback."""
    if not ip:
        return _fallback_geo("0.0.0.0")

    if _is_private_ip(ip):
        return _fallback_geo(ip)

    url = f"https://ip-api.com/json/{ip}?fields=status,message,country,regionName,city,lat,lon,query"
    request = Request(url, headers={"User-Agent": "CyberSentinel/1.0"})

    try:
        with urlopen(request, timeout=5) as response:
            payload = json.loads(response.read().decode("utf-8"))

        if payload.get("status") == "success":
            return GeoIPResult(
                ip=payload.get("query", ip),
                city=payload.get("city") or "Unknown",
                country=payload.get("country") or "Unknown",
                region=payload.get("regionName") or "Unknown",
                latitude=float(payload.get("lat") or 0.0),
                longitude=float(payload.get("lon") or 0.0),
                source="ip-api",
            )
    except (HTTPError, URLError, TimeoutError, ValueError, json.JSONDecodeError):
        pass

    return _fallback_geo(ip)