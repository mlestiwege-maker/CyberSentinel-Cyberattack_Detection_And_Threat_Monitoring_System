import 'package:flutter/foundation.dart';

class AppConfig extends ChangeNotifier {
  AppConfig._internal();

  static final AppConfig instance = AppConfig._internal();

  String twilioAccountSid = '';
  String twilioAuthToken = '';
  String twilioFromNumber = '';
  final List<String> groupEmails = [];

  void updateTwilio({required String accountSid, required String authToken, required String from}) {
    twilioAccountSid = accountSid;
    twilioAuthToken = authToken;
    twilioFromNumber = from;
    notifyListeners();
  }

  void addGroupEmail(String email) {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || groupEmails.contains(normalized)) {
      return;
    }
    groupEmails.add(normalized);
    notifyListeners();
  }

  void removeGroupEmail(String email) {
    groupEmails.remove(email.toLowerCase());
    notifyListeners();
  }
}
