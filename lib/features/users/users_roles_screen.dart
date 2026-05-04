import 'package:flutter/material.dart';
import '../../core/theme.dart';

class UsersRolesScreen extends StatelessWidget {
  const UsersRolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = [
      _TeamPerson('Admin', 'Security Analyst', 'Online', AppTheme.successGreen, 'Incident response and oversight'),
      _TeamPerson('Lestiwege Mufutumari', 'Frontend Developer', 'Online', AppTheme.accentBlue, 'Flutter UI and API integration'),
      _TeamPerson('Tadiwa Sharara', 'Project Planning', 'Online', AppTheme.warningOrange, 'Scope, requirements, architecture'),
      _TeamPerson('Bunu Anesu', 'Backend Development', 'Offline', AppTheme.textGrey, 'FastAPI APIs and business logic'),
      _TeamPerson('Madamu Creig', 'Network Monitoring', 'Online', AppTheme.successGreen, 'Traffic capture and preprocessing'),
      _TeamPerson('Davison Karamenti', 'Machine Learning', 'Online', AppTheme.accentBlue, 'Anomaly detection model integration'),
      _TeamPerson('Dzimbanhete Bhunu', 'Threat Detection', 'Online', AppTheme.warningOrange, 'Port scan and brute force detection'),
      _TeamPerson('Tinashe Matyamaenza', 'Testing', 'Online', AppTheme.successGreen, 'Unit, integration, and system testing'),
      _TeamPerson('Agatha Katiyo', 'Documentation', 'Offline', AppTheme.textGrey, 'Reports and presentation preparation'),
    ];

    final workstreams = [
      _Workstream('Project Planning', 'Tadiwa Sharara', 'Define scope, requirements, architecture', AppTheme.warningOrange),
      _Workstream('Backend Development', 'Bunu Anesu', 'Build FastAPI APIs and logic', AppTheme.accentBlue),
      _Workstream('Network Monitoring', 'Madamu Creig', 'Capture and preprocess network traffic', AppTheme.successGreen),
      _Workstream('Machine Learning', 'Davison Karamenti', 'Train and integrate anomaly detection model', AppTheme.accentBlue),
      _Workstream('Threat Detection', 'Dzimbanhete Bhunu', 'Implement port scan & brute force detection', AppTheme.warningOrange),
      _Workstream('Frontend Development', 'Mufutumari Lestiwege', 'Build Flutter UI and integrate APIs', AppTheme.successGreen),
      _Workstream('Admin Features', 'Shared Team', 'Incident response and role management', const Color(0xFF9B59FF)),
      _Workstream('Notifications', 'Shared Team', 'Email and SMS alerts integration', AppTheme.dangerRed),
      _Workstream('Testing', 'Tinashe Matyamaenza', 'Unit, integration and system testing', AppTheme.successGreen),
      _Workstream('Documentation', 'Agatha Katiyo', 'Prepare reports and presentation', AppTheme.textGrey),
    ];

    return _FeatureShell(
      title: 'Users, Roles & Team Tasks',
      subtitle: 'People, owners, and the workstreams each member is handling',
      child: ListView(
        children: [
          const Text(
            'TEAM MEMBERS',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...users.map((user) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBlack,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A3050)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: user.color.withOpacity(0.16),
                    child: Text(
                      user.name.characters.take(1).toString(),
                      style: TextStyle(color: user.color, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(user.role, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(user.assignment, style: const TextStyle(color: AppTheme.textGrey, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: user.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(user.status, style: TextStyle(color: user.color, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          const Text(
            'PROJECT WORKSTREAMS',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...workstreams.map(
            (task) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBlack,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A3050)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: task.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.title, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(task.owner, style: TextStyle(color: task.color, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(task.description, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamPerson {
  final String name;
  final String role;
  final String status;
  final Color color;
  final String assignment;

  _TeamPerson(this.name, this.role, this.status, this.color, this.assignment);
}

class _Workstream {
  final String title;
  final String owner;
  final String description;
  final Color color;

  _Workstream(this.title, this.owner, this.description, this.color);
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
