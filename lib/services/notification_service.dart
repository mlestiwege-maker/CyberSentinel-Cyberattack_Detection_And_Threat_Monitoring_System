import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String _baseUrl = 'https://cybersentinel-cyberattack-detection-and.onrender.com/api/v1';

  /// Send SMS via backend (which may use mock mode or Twilio based on server config)
  static Future<bool> sendSmsAlert({
    required String phoneNumber,
    required String message,
    required String? token,
  }) async {
    if (token == null || token.isEmpty) return false;

    try {
      final uri = Uri.parse('$_baseUrl/notifications/sms/test');
      final response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'phone_number': phoneNumber,
              'message': message,
            }),
          )
          .timeout(const Duration(seconds: 15));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  /// Send alert via email
  static Future<bool> sendEmailAlert({
    required List<String> recipients,
    required String subject,
    required String message,
    String? threatType,
    String? threatSeverity,
    String? threatSource,
    required String? token,
  }) async {
    if (token == null || token.isEmpty) return false;

    try {
      final uri = Uri.parse('$_baseUrl/notifications/email/send');
      final response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'recipients': recipients,
              'subject': subject,
              'message': message,
              'threat_type': threatType,
              'threat_severity': threatSeverity,
              'threat_source': threatSource,
            }),
          )
          .timeout(const Duration(seconds: 15));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  /// Test email configuration
  static Future<bool> testEmailConfiguration({
    required String testRecipient,
    required String? token,
  }) async {
    if (token == null || token.isEmpty) return false;

    try {
      final uri = Uri.parse('$_baseUrl/notifications/email/test');
      final response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'test_recipient': testRecipient,
            }),
          )
          .timeout(const Duration(seconds: 15));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  /// Test SMS configuration via backend
  static Future<bool> testSmsConfiguration({
    required String phoneNumber,
    required String message,
    required String? token,
  }) async {
    return sendSmsAlert(
      phoneNumber: phoneNumber,
      message: message,
      token: token,
    );
  }

  /// Get email configuration status
  static Future<Map<String, dynamic>?> getEmailStatus({
    required String? token,
  }) async {
    if (token == null || token.isEmpty) return null;

    try {
      final uri = Uri.parse('$_baseUrl/notifications/email/status');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get a snapshot of notification delivery status.
  static Future<Map<String, dynamic>?> getNotificationStatus({
    required String? token,
  }) async {
    if (token == null || token.isEmpty) return null;

    try {
      final uri = Uri.parse('$_baseUrl/notifications/status');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
