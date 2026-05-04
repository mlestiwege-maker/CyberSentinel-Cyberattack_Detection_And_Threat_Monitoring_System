import 'package:flutter/material.dart';
import '../../core/theme.dart';

class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  late List<_IncidentItem> _incidents;

  @override
  void initState() {
    super.initState();
    _incidents = [
      _IncidentItem('INC-2024-001', 'Open', 'Malware on workstation', AppTheme.dangerRed),
      _IncidentItem('INC-2024-002', 'In Progress', 'Unauthorized login attempt', AppTheme.warningOrange),
      _IncidentItem('INC-2024-003', 'Resolved', 'Phishing email reported', AppTheme.successGreen),
      _IncidentItem('INC-2024-004', 'Open', 'Suspicious outbound traffic', AppTheme.dangerRed),
    ];
  }

  void _setStatus(int index, String status) {
    final color = switch (status) {
      'Resolved' => AppTheme.successGreen,
      'In Progress' => AppTheme.warningOrange,
      _ => AppTheme.dangerRed,
    };
    setState(() {
      _incidents[index] = _IncidentItem(_incidents[index].id, status, _incidents[index].summary, color);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_incidents[index].id} set to $status')));
  }

  void _assign(int index) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_incidents[index].id} assigned to incident response team')));
    _setStatus(index, 'In Progress');
  }

  @override
  Widget build(BuildContext context) {
    return _FeatureShell(
      title: 'Incidents',
      subtitle: 'Track investigation workflow and response progress',
      child: ListView.separated(
        itemCount: _incidents.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final incident = _incidents[index];
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
                  backgroundColor: incident.color.withOpacity(0.15),
                  child: Text(incident.id.substring(4, 7), style: TextStyle(color: incident.color, fontSize: 10)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(incident.id, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(incident.summary, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: () => _assign(index),
                            child: const Text('Assign'),
                          ),
                          OutlinedButton(
                            onPressed: () => _setStatus(index, 'Resolved'),
                            child: const Text('Resolve'),
                          ),
                          OutlinedButton(
                            onPressed: () => _setStatus(index, 'Open'),
                            child: const Text('Reopen'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(incident.status, style: TextStyle(color: incident.color, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _IncidentItem {
  final String id;
  final String status;
  final String summary;
  final Color color;

  _IncidentItem(this.id, this.status, this.summary, this.color);
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
