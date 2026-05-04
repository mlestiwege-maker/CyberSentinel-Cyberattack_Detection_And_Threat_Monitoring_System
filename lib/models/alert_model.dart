class Alert {
  final String id;
  final String type;
  final String sourceIp;
  final String location;
  final String severity;
  final String status;
  final String time;

  Alert({
    required this.id,
    required this.type,
    required this.sourceIp,
    required this.location,
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
      severity: json['severity'] ?? 'Low',
      status: json['status'] ?? 'Detected',
      time: json['time'] ?? '',
    );
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
