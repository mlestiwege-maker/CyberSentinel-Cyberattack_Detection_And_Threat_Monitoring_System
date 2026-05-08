import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      _AlertItem('Brute Force', '192.168.1.45', 'Harare, Zimbabwe', 'HIGH', 'Detected', '10:45:21'),
      _AlertItem('Port Scan', '185.236.203.12', 'New York, USA', 'HIGH', 'Detected', '10:44:02'),
      _AlertItem('SQL Injection', '203.0.113.88', 'Berlin, Germany', 'MEDIUM', 'Detected', '10:43:11'),
      _AlertItem('Suspicious Login', '192.168.1.50', 'Harare, Zimbabwe', 'MEDIUM', 'Detected', '10:40:33'),
    ];

    return _FeatureShell(
      title: 'Alerts',
      subtitle: 'Active alert feed and risk overview',
      child: Column(
        children: [
          const Row(
            children: [
              _MiniStat(label: 'Open', value: '8', color: AppTheme.dangerRed),
              SizedBox(width: 12),
              _MiniStat(label: 'In Progress', value: '5', color: AppTheme.warningOrange),
              SizedBox(width: 12),
              _MiniStat(label: 'Resolved', value: '3', color: AppTheme.successGreen),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _AlertCard(alert: alerts[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final _AlertItem alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final severityColor = alert.severity == 'HIGH'
        ? AppTheme.dangerRed
        : alert.severity == 'MEDIUM'
            ? AppTheme.warningOrange
            : AppTheme.successGreen;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A3050)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: severityColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${alert.type} • ${alert.time}', style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('${alert.sourceIp} • ${alert.location}', style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(alert.severity, style: TextStyle(color: severityColor, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _AlertItem {
  final String type;
  final String sourceIp;
  final String location;
  final String severity;
  final String status;
  final String time;
  _AlertItem(this.type, this.sourceIp, this.location, this.severity, this.status, this.time);
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.secondaryBlack,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2A3050)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 11)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _FeatureShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _FeatureShell({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryBlack,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppTheme.textGrey)),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}
