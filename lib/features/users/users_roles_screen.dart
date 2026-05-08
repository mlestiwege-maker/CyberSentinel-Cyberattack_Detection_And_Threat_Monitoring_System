import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/access_control.dart';
import '../../services/api_service.dart';

class UsersRolesScreen extends StatefulWidget {
  const UsersRolesScreen({super.key});

  @override
  State<UsersRolesScreen> createState() => _UsersRolesScreenState();
}

class _UsersRolesScreenState extends State<UsersRolesScreen> {
  List<dynamic> _teamMembers = [];
  List<dynamic> _workstreams = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTeam();
  }

  Future<void> _loadTeam() async {
    try {
      final data = await ApiService.getTeamMembers();
      setState(() {
        _teamMembers = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _teamMembers = [
          {'name': 'Admin', 'role': 'Security Analyst', 'status': 'Online', 'color': 'success', 'assignment': 'Incident response and oversight', 'assignedRole': 'admin'},
          {'name': 'Lestiwege Mufutumari', 'role': 'Frontend Developer', 'status': 'Online', 'color': 'accent', 'assignment': 'Flutter UI and API integration', 'assignedRole': 'admin'},
          {'name': 'Tadiwa Sharara', 'role': 'Project Planning', 'status': 'Online', 'color': 'warning', 'assignment': 'Scope, requirements, architecture', 'assignedRole': 'security_analyst'},
          {'name': 'Bunu Anesu', 'role': 'Backend Development', 'status': 'Offline', 'color': 'grey', 'assignment': 'FastAPI APIs and business logic', 'assignedRole': 'incident_responder'},
          {'name': 'Madamu Creig', 'role': 'Network Monitoring', 'status': 'Online', 'color': 'success', 'assignment': 'Traffic capture and preprocessing', 'assignedRole': 'threat_monitor'},
          {'name': 'Davison Karamenti', 'role': 'Machine Learning', 'status': 'Online', 'color': 'accent', 'assignment': 'Anomaly detection model integration', 'assignedRole': 'testing'},
          {'name': 'Dzimbanhete Bhunu', 'role': 'Threat Detection', 'status': 'Online', 'color': 'warning', 'assignment': 'Port scan and brute force detection', 'assignedRole': 'incident_responder'},
          {'name': 'Tinashe Matyamaenza', 'role': 'Testing', 'status': 'Online', 'color': 'success', 'assignment': 'Unit, integration, and system testing', 'assignedRole': 'testing'},
          {'name': 'Agatha Katiyo', 'role': 'Documentation', 'status': 'Offline', 'color': 'grey', 'assignment': 'Reports and presentation preparation', 'assignedRole': 'documentation'},
        ];
        _loading = false;
      });
    }
  }

  Color _getColor(String color) {
    switch (color) {
      case 'success': return AppTheme.successGreen;
      case 'warning': return AppTheme.warningOrange;
      case 'accent': return AppTheme.accentBlue;
      default: return AppTheme.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AccessControl.instance,
      builder: (context, _) {
        final users = _teamMembers.map<_TeamPerson>((user) => _TeamPerson(
          user['name'],
          user['role'],
          user['status'],
          _getColor(user['color'] ?? 'success'),
          user['assignment'],
          user['assignedRole'],
        )).toList();

        final workstreams = [
          _Workstream('Project Planning', 'Tadiwa Sharara', 'Define scope, requirements, architecture', AppTheme.warningOrange, 'security_analyst'),
          _Workstream('Backend Development', 'Bunu Anesu', 'Build FastAPI APIs and logic', AppTheme.accentBlue, 'incident_responder'),
          _Workstream('Network Monitoring', 'Madamu Creig', 'Capture and preprocess network traffic', AppTheme.successGreen, 'threat_monitor'),
          _Workstream('Machine Learning', 'Davison Karamenti', 'Train and integrate anomaly detection model', AppTheme.accentBlue, 'testing'),
          _Workstream('Threat Detection', 'Dzimbanhete Bhunu', 'Implement port scan & brute force detection', AppTheme.warningOrange, 'incident_responder'),
          _Workstream('Frontend Development', 'Mufutumari Lestiwege', 'Build Flutter UI and integrate APIs', AppTheme.successGreen, 'admin'),
          _Workstream('Admin Features', 'Shared Team', 'Incident response and role management', Color(0xFF9B59FF), 'admin'),
          _Workstream('Notifications', 'Shared Team', 'Email and SMS alerts integration', AppTheme.dangerRed, 'admin'),
          _Workstream('Testing', 'Tinashe Matyamaenza', 'Unit, integration and system testing', AppTheme.successGreen, 'testing'),
          _Workstream('Documentation', 'Agatha Katiyo', 'Prepare reports and presentation', AppTheme.textGrey, 'documentation'),
        ];

        return _FeatureShell(
          title: 'Users, Roles & Team Tasks',
          subtitle: 'People, owners, and the workstreams each member is handling',
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
                    const Text(
                      'ACTIVE ROLE',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: AccessControl.instance.activeRole,
                      dropdownColor: AppTheme.secondaryBlack,
                      iconEnabledColor: AppTheme.accentBlue,
                      style: const TextStyle(color: AppTheme.textWhite),
                      underline: const SizedBox.shrink(),
                      items: AccessControl.instance.availableRoles
                          .map(
                            (role) => DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          AccessControl.instance.setRole(value);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Active role set to $value')));
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AccessControl.instance
                          .permissionsFor(AccessControl.instance.activeRole)
                          .map(
                            (permission) => Chip(
                              label: Text(permission),
                              backgroundColor: AppTheme.accentBlue.withOpacity(0.12),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const Text(
                'TEAM MEMBERS',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...users.map((user) {
                final isActiveRole = user.assignedRole == AccessControl.instance.activeRole;
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
                            const SizedBox(height: 6),
                            Text(
                              isActiveRole ? 'This role is currently active' : 'Assigned role: ${user.assignedRole}',
                              style: TextStyle(
                                color: isActiveRole ? AppTheme.successGreen : AppTheme.textGrey,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                            const SizedBox(height: 4),
                            Text('Permission: ${task.requiredRole}', style: const TextStyle(color: AppTheme.textGrey, fontSize: 11)),
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
      },
    );
  }
}

class _TeamPerson {
  final String name;
  final String role;
  final String status;
  final Color color;
  final String assignment;
  final String assignedRole;

  _TeamPerson(this.name, this.role, this.status, this.color, this.assignment, this.assignedRole);
}

class _Workstream {
  final String title;
  final String owner;
  final String description;
  final Color color;
  final String requiredRole;

  _Workstream(this.title, this.owner, this.description, this.color, this.requiredRole);
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