import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_storage.dart';
import 'notification_service.dart';

class AppConfig extends ChangeNotifier {
  AppConfig._internal();

  static final AppConfig instance = AppConfig._internal();

  String primaryEmail = '';
  String twilioAccountSid = '';
  String twilioAuthToken = '';
  String twilioFromNumber = '';
  final List<String> groupEmails = [];
  bool backendEmailConfigured = false;
  bool backendSmsConfigured = false;
  bool backendTwilioConfigured = false;
  String backendDeliveryHealth = 'manual';
  final List<String> backendEmailRecipients = [];
  final List<String> backendSmsRecipients = [];

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

    await refreshBackendStatus(token: state['backendAuthToken'] as String?);
  }

  Future<void> refreshBackendStatus({String? token}) async {
    final authToken = token?.trim() ?? '';
    if (authToken.isEmpty) {
      return;
    }

    final status = await NotificationService.getNotificationStatus(token: authToken);
    if (status == null) {
      return;
    }

    final sms = (status['sms'] as Map?)?.cast<String, dynamic>();
    final email = (status['email'] as Map?)?.cast<String, dynamic>();

    backendSmsConfigured = sms?['configured'] == true;
    backendTwilioConfigured = sms?['twilio_configured'] == true;
    backendEmailConfigured = email?['configured'] == true;
    backendDeliveryHealth = (status['delivery_health'] as String?) ?? 'manual';

    backendSmsRecipients
      ..clear()
      ..addAll(((sms?['recipients'] as List?) ?? const []).whereType<String>().map((value) => value.trim()));

    backendEmailRecipients
      ..clear()
      ..addAll(((email?['recipients'] as List?) ?? const []).whereType<String>().map((value) => value.trim().toLowerCase()));

    var shouldPersist = false;
    if (primaryEmail.isEmpty && backendEmailRecipients.isNotEmpty) {
      primaryEmail = backendEmailRecipients.first;
      shouldPersist = true;
    }
    if (groupEmails.isEmpty && backendEmailRecipients.isNotEmpty) {
      groupEmails
        ..clear()
        ..addAll(backendEmailRecipients);
      shouldPersist = true;
    }
    if (shouldPersist) {
      await _persist();
    } else {
      notifyListeners();
    }
  }

  void clearBackendStatus() {
    backendEmailConfigured = false;
    backendSmsConfigured = false;
    backendTwilioConfigured = false;
    backendDeliveryHealth = 'manual';
    backendEmailRecipients.clear();
    backendSmsRecipients.clear();
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
