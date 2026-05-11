from collections import defaultdict, deque
from config import config
from typing import Dict, Any, Optional, Tuple
import time


class LocalAnalyzer:
    """
    Stateful anomaly detector that runs locally — no backend required.

    Checks:
      1. Connection flood    — too many connections from one IP to one port
      2. Suspicious ports    — traffic to known attack-surface ports
      3. Traffic spike       — sudden surge in net I/O vs rolling average
    """

    def __init__(self):
        # (src_ip, dst_port) → deque of recent timestamps
        self.connection_counts: Dict = defaultdict(deque)
        self.last_traffic_bytes: int = 0
        # Rolling 60-second net_io history for spike detection
        self.traffic_history: deque = deque(maxlen=60)

    def check_anomalies(self, event: Dict[str, Any]) -> Optional[str]:
        """
        Inspect a normalised event and return an alert string if suspicious,
        or None if everything looks normal.
        """
        alert, _ = self._check_with_severity(event)
        return alert

    def check_anomalies_full(self, event: Dict[str, Any]) -> Tuple[Optional[str], str]:
        """
        Like check_anomalies but also returns the severity level:
        'low' | 'medium' | 'high' | 'critical'
        """
        return self._check_with_severity(event)

    # ── Internal ──────────────────────────────────────────────────────────────

    def _check_with_severity(self, event: Dict[str, Any]) -> Tuple[Optional[str], str]:
        now = time.time()

        if event['event_type'] == 'network_packet':
            return self._check_packet(event, now)

        if event['event_type'] == 'system_stats':
            return self._check_system_stats(event)

        return None, 'low'

    def _check_packet(self, event: Dict[str, Any], now: float) -> Tuple[Optional[str], str]:
        src  = event['src_ip']
        port = event['dst_port']

        # Track connection rate per (src_ip, dst_port)
        key = (src, port)
        self.connection_counts[key].append(now)
        # Prune entries older than 60 seconds
        while self.connection_counts[key] and now - self.connection_counts[key][0] > 60:
            self.connection_counts[key].popleft()

        recent = len(self.connection_counts[key])
        if recent > config.MAX_CONNS_PER_MIN:
            severity = 'critical' if recent > config.MAX_CONNS_PER_MIN * 2 else 'high'
            return (
                f"Connection flood from {src} to port {port} "
                f"({recent} connections/min)",
                severity,
            )

        # Suspicious port access
        if port in config.SUSPICIOUS_PORTS:
            return (
                f"Suspicious port access: {src} → port {port}",
                'medium',
            )

        return None, 'low'

    def _check_system_stats(self, event: Dict[str, Any]) -> Tuple[Optional[str], str]:
        net_io = event.get('net_io', 0)

        if self.last_traffic_bytes > 0 and net_io > 0:
            delta = net_io - self.last_traffic_bytes
            if self.last_traffic_bytes > 0:
                spike_pct = delta / self.last_traffic_bytes
                if spike_pct > config.TRAFFIC_SPIKE_PCT:
                    severity = 'critical' if spike_pct > config.TRAFFIC_SPIKE_PCT * 2 else 'high'
                    return (
                        f"Traffic spike detected: {spike_pct:.1%} increase",
                        severity,
                    )

        self.last_traffic_bytes = net_io
        return None, 'low'
