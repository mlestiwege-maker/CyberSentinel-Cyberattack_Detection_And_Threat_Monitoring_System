import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_storage.dart';

class AppConfig extends ChangeNotifier {
  AppConfig._internal();

  static final AppConfig instance = AppConfig._internal();

  String primaryEmail = '';
  String twilioAccountSid = '';
  String twilioAuthToken = '';
  String twilioFromNumber = '';
  final List<String> groupEmails = [];

  Future<void> load() async {
    final state = await AppStorage.readState();
    primaryEmail = state['primaryEmail'] as String? ?? '';
    twilioAccountSid = state['twilioAccountSid'] as String? ?? '';
    twilioAuthToken = state['twilioAuthToken'] as String? ?? '';
    twilioFromNumber = state['twilioFromNumber'] as String? ?? '';

    groupEmails
      ..clear()
      ..addAll(((state['groupEmails'] as List?) ?? const []).whereType<String>().map((email) => email.trim().toLowerCase()));

    notifyListeners();
  }

  Future<void> _persist() async {
    final state = await AppStorage.readState();
    state['primaryEmail'] = primaryEmail;
    state['twilioAccountSid'] = twilioAccountSid;
    state['twilioAuthToken'] = twilioAuthToken;
    state['twilioFromNumber'] = twilioFromNumber;
    state['groupEmails'] = groupEmails;
    await AppStorage.writeState(state);
  }

  void updatePrimaryEmail(String email) {
    primaryEmail = email.trim().toLowerCase();
    notifyListeners();
    unawaited(_persist());
  }

  void updateTwilio({required String accountSid, required String authToken, required String from}) {
    twilioAccountSid = accountSid;
    twilioAuthToken = authToken;
    twilioFromNumber = from;
    notifyListeners();
    unawaited(_persist());
  }

  void addGroupEmail(String email) {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || groupEmails.contains(normalized)) {
      return;
    }
    groupEmails.add(normalized);
    notifyListeners();
    unawaited(_persist());
  }

  void removeGroupEmail(String email) {
    groupEmails.remove(email.trim().toLowerCase());
    notifyListeners();
    unawaited(_persist());
  }
}
