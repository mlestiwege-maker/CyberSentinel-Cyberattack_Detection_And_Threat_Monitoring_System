import 'package:flutter/material.dart';
import '../../core/theme.dart';

class IncidentsScreen extends StatelessWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final incidents = [
      ('INC-2024-001', 'Open', 'Malware on workstation', AppTheme.dangerRed),
      ('INC-2024-002', 'In Progress', 'Unauthorized login attempt', AppTheme.warningOrange),
      ('INC-2024-003', 'Resolved', 'Phishing email reported', AppTheme.successGreen),
      ('INC-2024-004', 'Open', 'Suspicious outbound traffic', AppTheme.dangerRed),
    ];

    return _FeatureShell(
      title: 'Incidents',
      subtitle: 'Track investigation workflow and response progress',
      child: ListView.separated(
        itemCount: incidents.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final incident = incidents[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBlack,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2A3050)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: incident.$4.withOpacity(0.15),
                  child: Text(incident.$1.substring(4, 7), style: TextStyle(color: incident.$4, fontSize: 10)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(incident.$1, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(incident.$3, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                    ],
                  ),
                ),
                Text(incident.$2, style: TextStyle(color: incident.$4, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          );
        },
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
