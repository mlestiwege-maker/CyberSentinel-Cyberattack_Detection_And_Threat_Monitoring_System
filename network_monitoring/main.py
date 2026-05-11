from collector import capture_traffic
from parsers import normalize_event
from local_analyzer import LocalAnalyzer
from producer import send_event
from config import config


def main():
    analyzer = LocalAnalyzer()

    print(f"🛡️  CyberSentinel Network Monitor starting...")
    print(f"   Interface : {config.INTERFACE}")
    print(f"   Backend   : {config.BACKEND_URL or 'None (logging locally)'}")
    print(f"   Events log: {config.EVENTS_LOG}")
    print(f"   Alerts log: {config.ALERTS_LOG}")
    print("─" * 50)

    for raw_event in capture_traffic(config.INTERFACE, config.SAMPLE_RATE):
        event = normalize_event(raw_event)
        alert, severity = analyzer.check_anomalies_full(event)
        send_event(event, alert, severity)


if __name__ == "__main__":
    main()
