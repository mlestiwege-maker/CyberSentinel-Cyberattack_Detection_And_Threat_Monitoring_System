import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_storage.dart';

class AccessControl extends ChangeNotifier {
  AccessControl._internal();

  static final AccessControl instance = AccessControl._internal();

  final List<String> availableRoles = const [
    'Admin',
    'Security Analyst',
    'Incident Responder',
    'Threat Monitor',
    'Frontend Developer',
    'Testing',
    'Documentation',
  ];

  final Map<String, Set<String>> _permissions = const {
    'Admin': {
      'reports.export',
      'incidents.manage',
      'monitoring.refresh',
      'voice.command',
      'twilio.send',
      'settings.edit',
      'role.change',
    },
    'Security Analyst': {
      'reports.export',
      'incidents.manage',
      'monitoring.refresh',
      'voice.command',
      'twilio.send',
    },
    'Incident Responder': {
      'incidents.manage',
      'voice.command',
      'twilio.send',
    },
    'Threat Monitor': {
      'monitoring.refresh',
      'voice.command',
    },
    'Frontend Developer': {
      'reports.export',
      'voice.command',
    },
    'Testing': {
      'reports.export',
      'monitoring.refresh',
      'voice.command',
    },
    'Documentation': {
      'reports.export',
      'voice.command',
    },
  };

  String activeRole = 'Admin';

  Future<void> load() async {
    final state = await AppStorage.readState();
    final storedRole = state['activeRole'] as String?;
    if (storedRole != null && storedRole.isNotEmpty && availableRoles.contains(storedRole)) {
      activeRole = storedRole;
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final state = await AppStorage.readState();
    state['activeRole'] = activeRole;
    await AppStorage.writeState(state);
  }

  void setRole(String role) {
    if (!availableRoles.contains(role) || activeRole == role) {
      return;
    }
    activeRole = role;
    notifyListeners();
    unawaited(_persist());
  }

  bool canPerform(String permission) {
    return _permissions[activeRole]?.contains(permission) ?? false;
  }

  void setRoleFromBackend(String backendRole) {
    final normalized = backendRole.trim().toLowerCase();
    final mappedRole = switch (normalized) {
      'admin' => 'Admin',
      'security analyst' => 'Security Analyst',
      'analyst' => 'Security Analyst',
      'incident responder' => 'Incident Responder',
      'threat monitor' => 'Threat Monitor',
      'documentation' => 'Documentation',
      'viewer' => 'Documentation',
      _ => activeRole,
    };
    setRole(mappedRole);
  }

  Set<String> permissionsFor(String role) {
    return _permissions[role] ?? const {};
  }
}