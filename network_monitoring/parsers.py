from typing import Dict, Any


def normalize_event(raw_event: Dict[str, Any]) -> Dict[str, Any]:
    """
    Normalize a raw packet or system-stats dict into the standard
    CyberSentinel event schema that the backend and Flutter UI expect.

    Input shapes:
      - network_packet: has src_ip, dst_ip, src_port, dst_port, protocol, bytes
      - system_stats:   has cpu_pct, net_io, connections

    Returns a flat dict with all fields present (missing ones set to None/0).
    """
    return {
        'timestamp':   raw_event['timestamp'],
        'event_type':  'network_packet' if 'src_ip' in raw_event else 'system_stats',
        'src_ip':      raw_event.get('src_ip',   'unknown'),
        'dst_ip':      raw_event.get('dst_ip',   'unknown'),
        'src_port':    raw_event.get('src_port'),
        'dst_port':    raw_event.get('dst_port'),
        'protocol':    raw_event.get('protocol', 'unknown'),
        'bytes':       raw_event.get('bytes', 0),
        'cpu_pct':     raw_event.get('cpu_pct'),
        'connections': raw_event.get('connections'),
    }
