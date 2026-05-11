import os
from dataclasses import dataclass, field
from datetime import datetime
import json

@dataclass
class Config:
    # Network interface to monitor ('lo' works on any machine without root)
    INTERFACE: str = os.getenv('MONITOR_INTERFACE', 'lo')
    SAMPLE_RATE: int = int(os.getenv('SAMPLE_RATE', '100'))

    # CyberSentinel backend URL — set this to Bunu Anesu's backend address
    # Leave as None to run in standalone/log-only mode
    BACKEND_URL: str = os.getenv('BACKEND_URL', None)

    # Local log files (written to the network_monitoring/ folder)
    EVENTS_LOG: str = os.getenv('EVENTS_LOG', 'events.jsonl')
    ALERTS_LOG: str = os.getenv('ALERTS_LOG', 'alerts.jsonl')

    # Anomaly detection thresholds
    MAX_CONNS_PER_MIN: int = int(os.getenv('MAX_CONNS_PER_MIN', '1000'))
    SUSPICIOUS_PORTS: set = field(
        default_factory=lambda: {
            int(p) for p in os.getenv(
                'SUSPICIOUS_PORTS', '22,23,445,3389'
            ).split(',')
        }
    )
    TRAFFIC_SPIKE_PCT: float = float(os.getenv('TRAFFIC_SPIKE_PCT', '2.0'))

config = Config()


def log_to_file(filename: str, data: dict):
    """Append a JSON event to a local log file."""
    with open(filename, 'a') as f:
        data['logged_at'] = datetime.now().isoformat()
        f.write(json.dumps(data) + '\n')
