import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';

class AuthSession {
  final String accessToken;
  final String fullName;
  final String email;
  final String role;

  AuthSession({
    required this.accessToken,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['access_token'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}

class AuthService {
  AuthService._();

  static Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.apiVersion}/auth/login'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email.trim(),
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final decoded = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic> ? decoded['detail']?.toString() : null;
      throw Exception(message ?? 'Login failed');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected login response');
    }

    return AuthSession.fromJson(decoded);
  }
}
