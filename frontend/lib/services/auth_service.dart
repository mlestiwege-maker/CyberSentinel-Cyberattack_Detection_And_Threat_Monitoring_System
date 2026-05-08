import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.apiVersion}/auth/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    final body = _decodeError(response.body);
    throw Exception(body);
  }

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.apiVersion}/auth/register'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
        'role': _mapRole(role),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    final body = _decodeError(response.body);
    throw Exception(body);
  }

  static Future<Map<String, dynamic>> me(String token) async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.apiVersion}/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    final body = _decodeError(response.body);
    throw Exception(body);
  }

  static String _mapRole(String role) {
    switch (role) {
      case 'Admin':
        return 'admin';
      case 'Security Analyst':
        return 'analyst';
      default:
        return 'viewer';
    }
  }

  static String _decodeError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['detail'] != null) {
        return decoded['detail'].toString();
      }
    } catch (_) {
      // ignore
    }
    return 'Authentication request failed';
  }
}