import 'dart:async';

import 'package:flutter/foundation.dart';

import 'auth_service.dart';
import 'app_storage.dart';

class AppConfig extends ChangeNotifier {
  AppConfig._internal();

  static final AppConfig instance = AppConfig._internal();

  bool isAuthenticated = false;
  String backendUserName = '';
  String backendUserEmail = '';
  String backendUserRole = '';
  String backendAuthToken = '';
  String twilioAccountSid = '';
  String twilioAuthToken = '';
  String twilioFromNumber = '';
  final List<String> groupEmails = [];

  Future<void> load() async {
    final state = await AppStorage.readState();
    isAuthenticated = state['isAuthenticated'] as bool? ?? false;
    backendUserName = state['backendUserName'] as String? ?? '';
    backendUserEmail = state['backendUserEmail'] as String? ?? '';
    backendUserRole = state['backendUserRole'] as String? ?? '';
    backendAuthToken = state['backendAuthToken'] as String? ?? '';
    if (backendAuthToken.isNotEmpty) {
      try {
        final user = await AuthService.me(backendAuthToken);
        isAuthenticated = true;
        backendUserName = user['full_name']?.toString() ?? backendUserName;
        backendUserEmail = user['email']?.toString() ?? backendUserEmail;
        backendUserRole = user['role']?.toString() ?? backendUserRole;
        await _persist();
      } catch (error) {
        final errorText = error.toString().toLowerCase();
        final isAuthFailure = errorText.contains('401') || errorText.contains('403') || errorText.contains('unauthorized') || errorText.contains('forbidden');
        isAuthenticated = false;
        if (isAuthFailure) {
          backendAuthToken = '';
          backendUserName = '';
          backendUserEmail = '';
          backendUserRole = '';
          await _persist();
        }
      }
    }
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
    state['isAuthenticated'] = isAuthenticated;
    state['backendUserName'] = backendUserName;
    state['backendUserEmail'] = backendUserEmail;
    state['backendUserRole'] = backendUserRole;
    state['backendAuthToken'] = backendAuthToken;
    state['twilioAccountSid'] = twilioAccountSid;
    state['twilioAuthToken'] = twilioAuthToken;
    state['twilioFromNumber'] = twilioFromNumber;
    state['groupEmails'] = groupEmails;
    await AppStorage.writeState(state);
  }

  void updateBackendSession({
    required String token,
    required String name,
    required String email,
    required String role,
  }) {
    isAuthenticated = token.trim().isNotEmpty;
    backendAuthToken = token.trim();
    backendUserName = name.trim();
    backendUserEmail = email.trim();
    backendUserRole = role.trim();
    notifyListeners();
    unawaited(_persist());
  }

  void clearBackendSession() {
    isAuthenticated = false;
    backendAuthToken = '';
    backendUserName = '';
    backendUserEmail = '';
    backendUserRole = '';
    notifyListeners();
    unawaited(_persist());
  }

  void updateBackendAuthToken(String token) {
    updateBackendSession(token: token, name: backendUserName, email: backendUserEmail, role: backendUserRole);
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
