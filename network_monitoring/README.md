# Network Monitoring Module
**CyberSentinel — Cyberattack Detection & Threat Monitoring System**
**Owner: Madamu Craig**

---

## What this module does

This is the live network traffic capture and analysis engine for CyberSentinel. It runs as a standalone Python process that:

1. **Captures** live packets off a network interface using Scapy
2. **Normalises** each packet into a standard event schema
3. **Analyses** events locally for anomalies (connection floods, suspicious ports, traffic spikes)
4. **Forwards** events and alerts to the CyberSentinel backend — or logs them to local files if the backend is offline

It works in two modes:
- **Connected mode** — sends events to Bunu Anesu's backend API in real-time
- **Standalone mode** — logs everything to `events.jsonl` and `alerts.jsonl` locally (no backend needed)

---

## Project structure

```
network_monitoring/
├── main.py            ← Entry point — run this
├── collector.py       ← Packet capture (Scapy) + system stats (psutil)
├── parsers.py         ← Normalises raw packets into standard schema
├── local_analyzer.py  ← Anomaly detection (connection floods, port scans, spikes)
├── producer.py        ← Sends events to backend or logs locally
├── config.py          ← All settings (env-var driven)
├── requirements.txt   ← Python dependencies
└── events.jsonl       ← Auto-created when running in standalone mode
```

---

## Setup

### 1. Navigate to the module folder

```bash
cd network_monitoring
```

### 2. Create a virtual environment (recommended)

```bash
python -m venv venv
source venv/bin/activate        # Linux / macOS
venv\Scripts\activate           # Windows
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

---

## Running the module

### Standalone mode (no backend needed)

```bash
python main.py
```

Events are written to `events.jsonl` and alerts to `alerts.jsonl` in the same folder.

### Connected to CyberSentinel backend

```bash
BACKEND_URL=http://localhost:8000 python main.py
```

Replace `http://localhost:8000` with the actual backend URL when deployed.

### Custom interface

```bash
MONITOR_INTERFACE=eth0 python main.py    # use eth0 instead of loopback
MONITOR_INTERFACE=wlan0 python main.py   # use Wi-Fi interface
```

> **Note:** Capturing on interfaces other than `lo` (loopback) requires root/admin privileges.
> Run with `sudo python main.py` on Linux/macOS if you get a permission error.

---

## Configuration

All settings are controlled by environment variables — no code changes needed:

| Variable | Default | Description |
|----------|---------|-------------|
| `MONITOR_INTERFACE` | `lo` | Network interface to capture on |
| `SAMPLE_RATE` | `100` | Max packets processed per second |
| `BACKEND_URL` | `None` | CyberSentinel backend base URL |
| `EVENTS_LOG` | `events.jsonl` | Path for event log file |
| `ALERTS_LOG` | `alerts.jsonl` | Path for alert log file |
| `MAX_CONNS_PER_MIN` | `1000` | Threshold before connection flood alert |
| `SUSPICIOUS_PORTS` | `22,23,445,3389` | Comma-separated ports to flag |
| `TRAFFIC_SPIKE_PCT` | `2.0` | Multiplier for traffic spike detection |

---

## What the output looks like

### Console (standalone mode)

```
🛡️  CyberSentinel Network Monitor starting...
   Interface : lo
   Backend   : None (logging locally)
   Events log: events.jsonl
   Alerts log: alerts.jsonl
──────────────────────────────────────────────────
📊 Logged: 2026-05-11T10:00:01
📊 Logged: 2026-05-11T10:00:02
🚨 ALERT [HIGH]: Suspicious port access: 192.168.1.5 → port 22 | 192.168.1.5 | 2026-05-11T10:00:03
📊 Logged: 2026-05-11T10:00:04
```

### events.jsonl (one JSON object per line)

```json
{"timestamp": "2026-05-11T10:00:01", "event_type": "network_packet", "src_ip": "127.0.0.1", "dst_ip": "127.0.0.1", "src_port": 54321, "dst_port": 80, "protocol": "TCP", "bytes": 74, "cpu_pct": null, "connections": null, "severity": "low", "logged_at": "2026-05-11T10:00:01.123"}
```

### alerts.jsonl (only alert events)

```json
{"timestamp": "2026-05-11T10:00:03", "event_type": "network_packet", "src_ip": "192.168.1.5", "dst_port": 22, "protocol": "TCP", "alert": "Suspicious port access: 192.168.1.5 → port 22", "severity": "medium", "logged_at": "2026-05-11T10:00:03.456"}
```

---

## Anomaly detection

The `LocalAnalyzer` detects three threat types:

| Threat | Trigger | Severity |
|--------|---------|---------|
| **Connection flood** | >1000 connections/min from one IP to one port | HIGH / CRITICAL |
| **Suspicious port access** | Traffic to ports 22, 23, 445, 3389 | MEDIUM |
| **Traffic spike** | Net I/O increases by >200% vs previous reading | HIGH / CRITICAL |

---

## How it connects to the rest of CyberSentinel

```
[This module]                    [Bunu Anesu — Backend]
collector.py  ──packets──►  parsers.py  ──►  local_analyzer.py
                                                    │
                                               producer.py
                                                    │
                              ┌─────────────────────┴──────────────────────┐
                              │                                             │
                    BACKEND_URL set?                                   No backend
                              │                                             │
                   POST /api/v1/network-monitor/ingest            events.jsonl
                              │                                    alerts.jsonl
                    [Flutter UI reads alerts]
```

---

## How to push your work

```bash
# From the project root
git checkout -b feature/network-monitor-madamu

git add network_monitoring/main.py
git add network_monitoring/collector.py
git add network_monitoring/parsers.py
git add network_monitoring/local_analyzer.py
git add network_monitoring/producer.py
git add network_monitoring/config.py
git add network_monitoring/requirements.txt
git add network_monitoring/README.md

git commit -m "feat: add network monitoring module (Madamu Creig)

- Live packet capture via Scapy on configurable interface
- System stats (CPU, net I/O, connections) every 10s via psutil
- LocalAnalyzer: connection flood, suspicious ports, traffic spike detection
- Dual-mode producer: CyberSentinel backend or local JSONL logging
- Fully env-var configurable, no code changes needed for deployment"

git push origin feature/network-monitor-madamu
```

Then open a Pull Request on GitHub to merge into `main`.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `Permission denied` on capture | Run with `sudo python main.py` |
| `ModuleNotFoundError: scapy` | Run `pip install -r requirements.txt` inside the venv |
| No packets captured on `lo` | Run `ping 127.0.0.1` in another terminal to generate loopback traffic |
| Backend connection refused | Normal — module falls back to local logging automatically |
| `events.jsonl` not created | Make sure you have write permission in the `network_monitoring/` folder |

---

*Part of the CyberSentinel university group cybersecurity project.*
