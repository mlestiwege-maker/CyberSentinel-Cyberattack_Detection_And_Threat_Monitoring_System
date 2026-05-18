import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_config.dart';
import 'app_storage.dart';

class AppState extends ChangeNotifier {
  AppState._internal();

  static final AppState instance = AppState._internal();

  bool isDarkMode = true;
  bool notificationsEnabled = true;
  bool autoRefreshEnabled = true;
  bool isAuthenticated = false;
  String backendAuthToken = '';
  String backendUserName = '';
  String backendUserEmail = '';
  String backendUserRole = '';

  Future<void> load() async {
    final state = await AppStorage.readState();
    isDarkMode = state['isDarkMode'] as bool? ?? true;
    notificationsEnabled = state['notificationsEnabled'] as bool? ?? true;
    autoRefreshEnabled = state['autoRefreshEnabled'] as bool? ?? true;
    isAuthenticated = state['isAuthenticated'] as bool? ?? false;
    backendAuthToken = state['backendAuthToken'] as String? ?? '';
    backendUserName = state['backendUserName'] as String? ?? '';
    backendUserEmail = state['backendUserEmail'] as String? ?? '';
    backendUserRole = state['backendUserRole'] as String? ?? '';
    notifyListeners();
  }

  Future<void> _persist() async {
    final state = await AppStorage.readState();
    state['isDarkMode'] = isDarkMode;
    state['notificationsEnabled'] = notificationsEnabled;
    state['autoRefreshEnabled'] = autoRefreshEnabled;
    state['isAuthenticated'] = isAuthenticated;
    state['backendAuthToken'] = backendAuthToken;
    state['backendUserName'] = backendUserName;
    state['backendUserEmail'] = backendUserEmail;
    state['backendUserRole'] = backendUserRole;
    await AppStorage.writeState(state);
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
    unawaited(_persist());
  }

  void setDarkMode(bool value) {
    isDarkMode = value;
    notifyListeners();
    unawaited(_persist());
  }

  void setNotificationsEnabled(bool value) {
    notificationsEnabled = value;
    notifyListeners();
    unawaited(_persist());
  }

  void setAutoRefreshEnabled(bool value) {
    autoRefreshEnabled = value;
    notifyListeners();
    unawaited(_persist());
  }

  void setAuthenticatedUser({
    required String token,
    required String name,
    required String email,
    required String role,
  }) {
    isAuthenticated = true;
    backendAuthToken = token;
    backendUserName = name;
    backendUserEmail = email;
    backendUserRole = role;
    notifyListeners();
    unawaited(_persist());
    unawaited(AppConfig.instance.refreshBackendStatus(token: token));
  }

  void logout() {
    isAuthenticated = false;
    backendAuthToken = '';
    backendUserName = '';
    backendUserEmail = '';
    backendUserRole = '';
    notifyListeners();
    unawaited(_persist());
    AppConfig.instance.clearBackendStatus();
  }
}
