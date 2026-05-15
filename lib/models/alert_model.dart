class Alert {
  final String id;
  final String type;
  final String sourceIp;
  final String location;
  final String city;
  final String country;
  final double? latitude;
  final double? longitude;
  final String severity;
  final String status;
  final String time;

  Alert({
    required this.id,
    required this.type,
    required this.sourceIp,
    required this.location,
    this.city = 'Unknown',
    this.country = 'Unknown',
    this.latitude,
    this.longitude,
    required this.severity,
    required this.status,
    required this.time,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'].toString(),
      type: json['type'] ?? 'Unknown',
      sourceIp: json['source_ip'] ?? 'N/A',
      location: json['location'] ?? 'Unknown',
      city: json['city'] ?? 'Unknown',
      country: json['country'] ?? 'Unknown',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      severity: json['severity'] ?? 'Low',
      status: json['status'] ?? 'Detected',
      time: json['time'] ?? '',
    );
  }

  factory Alert.fromThreatJson(Map<String, dynamic> json) {
    final sourceIp = (json['source_ip'] ?? '').toString();
    final threatType = (json['threat_type'] ?? 'unknown').toString().replaceAll('_', ' ');
    final severity = (json['severity'] ?? 'low').toString().toUpperCase();
    final isResolved = (json['is_resolved'] ?? 0).toString() == '1';
    final detectedAt = (json['detected_at'] ?? '').toString();

    return Alert(
      id: (json['id'] ?? '').toString(),
      type: threatType.isEmpty ? 'Unknown' : _toTitleCase(threatType),
      sourceIp: sourceIp.isEmpty ? 'N/A' : sourceIp,
      location: _locationFromIp(sourceIp),
      city: _cityFromGeo(json),
      country: _countryFromGeo(json),
      latitude: _toDouble(json['latitude'] ?? (json['geo'] is Map ? (json['geo'] as Map)['lat'] : null)),
      longitude: _toDouble(json['longitude'] ?? (json['geo'] is Map ? (json['geo'] as Map)['lng'] : null)),
      severity: severity,
      status: isResolved ? 'RESOLVED' : 'DETECTED',
      time: _formatTime(detectedAt),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String _formatTime(String iso) {
    if (iso.isEmpty) return '--:--:--';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '--:--:--';
    final local = dt.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    final ss = local.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  static String _locationFromIp(String ip) {
    if (ip.isEmpty || ip == 'N/A') return 'Unknown';
    if (ip.startsWith('10.') || ip.startsWith('192.168.') || _is172Private(ip)) {
      return 'Internal Network';
    }
    return 'External Network';
  }

  static String _cityFromGeo(Map<String, dynamic> json) {
    final geo = json['geo'];
    if (geo is Map) {
      return (geo['city'] ?? 'Unknown').toString();
    }
    return (json['city'] ?? 'Unknown').toString();
  }

  static String _countryFromGeo(Map<String, dynamic> json) {
    final geo = json['geo'];
    if (geo is Map) {
      return (geo['country'] ?? 'Unknown').toString();
    }
    return (json['country'] ?? 'Unknown').toString();
  }

  static bool _is172Private(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    final first = int.tryParse(parts[0]);
    final second = int.tryParse(parts[1]);
    if (first == null || second == null) return false;
    return first == 172 && second >= 16 && second <= 31;
  }

  static String _toTitleCase(String value) {
    return value
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'source_ip': sourceIp,
        'location': location,
        'severity': severity,
        'status': status,
        'time': time,
      };
}
