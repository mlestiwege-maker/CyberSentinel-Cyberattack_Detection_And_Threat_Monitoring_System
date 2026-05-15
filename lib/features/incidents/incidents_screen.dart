import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../services/access_control.dart';

class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  late List<_IncidentItem> _incidents;
  final List<_IncidentEvent> _timeline = [];

  @override
  void initState() {
    super.initState();
    _incidents = [
      _IncidentItem('INC-2024-001', 'Open', 'Malware on workstation', AppTheme.dangerRed, DateTime.now()),
      _IncidentItem('INC-2024-002', 'In Progress', 'Unauthorized login attempt', AppTheme.warningOrange, DateTime.now()),
      _IncidentItem('INC-2024-003', 'Resolved', 'Phishing email reported', AppTheme.successGreen, DateTime.now()),
      _IncidentItem('INC-2024-004', 'Open', 'Suspicious outbound traffic', AppTheme.dangerRed, DateTime.now()),
    ];

    for (final incident in _incidents) {
      _timeline.add(_IncidentEvent(incident.id, 'Loaded with status ${incident.status}', incident.status, incident.lastUpdated));
    }
  }

  void _setStatus(int index, String status) {
    if (!AccessControl.instance.canPerform('incidents.manage')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current role cannot update incidents')));
      return;
    }

    final color = switch (status) {
      'Resolved' => AppTheme.successGreen,
      'In Progress' => AppTheme.warningOrange,
      _ => AppTheme.dangerRed,
    };
    final now = DateTime.now();
    setState(() {
      _incidents[index] = _IncidentItem(_incidents[index].id, status, _incidents[index].summary, color, now);
      _timeline.insert(0, _IncidentEvent(_incidents[index].id, 'Status changed to $status', status, now));
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_incidents[index].id} set to $status')));
  }

  void _assign(int index) {
    if (!AccessControl.instance.canPerform('incidents.manage')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current role cannot assign incidents')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_incidents[index].id} assigned to incident response team')));
    _setStatus(index, 'In Progress');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AccessControl.instance,
      builder: (context, _) {
        final canManage = AccessControl.instance.canPerform('incidents.manage');

        return _FeatureShell(
          title: 'Incidents',
          subtitle: 'Track investigation workflow and response progress',
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBlack,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2A3050)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('INCIDENT HISTORY TIMELINE', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ..._timeline.take(4).map(
                      (event) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: event.color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${event.incidentId} • ${event.message}',
                                style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                              ),
                            ),
                            Text(
                              DateFormat('HH:mm').format(event.timestamp),
                              style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                          backgroundColor: incident.color.withValues(alpha: 0.15),
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
                              const SizedBox(height: 4),
                              Text(
                                'Last updated: ${DateFormat('yyyy-MM-dd HH:mm').format(incident.lastUpdated)}',
                                style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: canManage ? () => _assign(index) : null,
                                    child: const Text('Assign'),
                                  ),
                                  OutlinedButton(
                                    onPressed: canManage ? () => _setStatus(index, 'Resolved') : null,
                                    child: const Text('Resolve'),
                                  ),
                                  OutlinedButton(
                                    onPressed: canManage ? () => _setStatus(index, 'Open') : null,
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
            ],
          ),
        );
      },
    );
  }
}

class _IncidentItem {
  final String id;
  final String status;
  final String summary;
  final Color color;
  final DateTime lastUpdated;

  _IncidentItem(this.id, this.status, this.summary, this.color, this.lastUpdated);
}

class _IncidentEvent {
  final String incidentId;
  final String message;
  final String status;
  final DateTime timestamp;
  final Color color;

  _IncidentEvent(this.incidentId, this.message, this.status, this.timestamp)
      : color = switch (status) {
          'Resolved' => AppTheme.successGreen,
          'In Progress' => AppTheme.warningOrange,
          _ => AppTheme.dangerRed,
        };
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
