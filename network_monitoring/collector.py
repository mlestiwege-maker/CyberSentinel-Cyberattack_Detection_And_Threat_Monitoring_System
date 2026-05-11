from scapy.all import sniff, IP, TCP, UDP
import psutil
import time
from datetime import datetime
from typing import Generator, Dict, Any


def capture_traffic(interface: str, sample_rate: int) -> Generator[Dict[str, Any], None, None]:
    """
    Capture live network packets on `interface` and yield system stats.

    Yields two event shapes:
      - network_packet: one per captured IP packet
      - system_stats:   CPU/network/connection snapshot every 10 seconds

    Args:
        interface:   Network interface name, e.g. 'lo', 'eth0', 'wlan0'
        sample_rate: Max packets processed per second (rate limiter)
    """
    captured = []

    def _packet_handler(packet):
        if IP in packet:
            captured.append({
                'timestamp': datetime.now().isoformat(),
                'src_ip':    packet[IP].src,
                'dst_ip':    packet[IP].dst,
                'src_port':  packet[TCP].sport if TCP in packet
                             else packet[UDP].sport if UDP in packet
                             else None,
                'dst_port':  packet[TCP].dport if TCP in packet
                             else packet[UDP].dport if UDP in packet
                             else None,
                'protocol':  'TCP' if TCP in packet
                             else 'UDP' if UDP in packet
                             else 'OTHER',
                'bytes':     len(packet),
            })

    last_stats_time = time.time()

    while True:
        # Capture packets in 1-second bursts
        sniff(iface=interface, prn=_packet_handler, store=False, timeout=1)

        # Yield all captured packets, respecting sample rate
        for raw in captured:
            yield raw
            time.sleep(1 / sample_rate)
        captured.clear()

        # Yield system stats every 10 seconds
        now = time.time()
        if now - last_stats_time >= 10:
            net_io = psutil.net_io_counters()
            yield {
                'timestamp':   datetime.now().isoformat(),
                'type':        'system_stats',
                'cpu_pct':     psutil.cpu_percent(),
                'net_io':      net_io.bytes_sent + net_io.bytes_recv,
                'connections': len(psutil.net_connections()),
            }
            last_stats_time = now
