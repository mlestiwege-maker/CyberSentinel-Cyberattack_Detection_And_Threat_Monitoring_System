import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  AppState._internal();

  static final AppState instance = AppState._internal();

  bool isDarkMode = true;
  bool notificationsEnabled = true;
  bool autoRefreshEnabled = true;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    isDarkMode = value;
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void setAutoRefreshEnabled(bool value) {
    autoRefreshEnabled = value;
    notifyListeners();
  }
}
