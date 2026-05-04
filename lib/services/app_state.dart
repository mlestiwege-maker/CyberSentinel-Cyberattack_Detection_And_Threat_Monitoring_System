import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_storage.dart';

class AppState extends ChangeNotifier {
  AppState._internal();

  static final AppState instance = AppState._internal();

  bool isDarkMode = true;
  bool notificationsEnabled = true;
  bool autoRefreshEnabled = true;

  Future<void> load() async {
    final state = await AppStorage.readState();
    isDarkMode = state['isDarkMode'] as bool? ?? true;
    notificationsEnabled = state['notificationsEnabled'] as bool? ?? true;
    autoRefreshEnabled = state['autoRefreshEnabled'] as bool? ?? true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final state = await AppStorage.readState();
    state['isDarkMode'] = isDarkMode;
    state['notificationsEnabled'] = notificationsEnabled;
    state['autoRefreshEnabled'] = autoRefreshEnabled;
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
}
