import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/alert_model.dart';
import 'app_config.dart';

class ApiService {
  static Map<String, String> _headers({bool jsonBody = false}) {
    final headers = <String, String>{};
    if (jsonBody) {
      headers['Content-Type'] = 'application/json';
    }

    final token = AppConfig.instance.backendAuthToken.trim();
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<List<Alert>> fetchAlerts() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.alertsEndpoint),
        headers: _headers(),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List alertsJson = data is List ? data : data['alerts'] ?? [];
        return alertsJson.map((e) => Alert.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load alerts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching alerts: $e');
    }
  }

  static Future<dynamic> fetchThreats() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.threatsEndpoint),
        headers: _headers(),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load threats');
      }
    } catch (e) {
      throw Exception('Error fetching threats: $e');
    }
  }

  static Future<dynamic> fetchIncidents() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.incidentsEndpoint),
        headers: _headers(),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load incidents');
      }
    } catch (e) {
      throw Exception('Error fetching incidents: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchDashboardSummary() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.dashboardSummaryEndpoint),
        headers: _headers(),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load dashboard summary');
      }
    } catch (e) {
      throw Exception('Error fetching dashboard summary: $e');
    }
  }

  static Future<dynamic> sendSms({required String to, required String body}) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.twilioSendEndpoint),
        headers: _headers(jsonBody: true),
        body: jsonEncode({'to': to, 'body': body}),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send SMS');
      }
    } catch (e) {
      throw Exception('Error sending SMS: $e');
    }
  }

  static Future<Map<String, dynamic>> processVoiceCommand(String command) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.voiceCommandEndpoint),
        headers: _headers(jsonBody: true),
        body: jsonEncode({'command': command}),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to process voice command');
      }
    } catch (e) {
      throw Exception('Error processing voice command: $e');
    }
  }

  static Future<List<dynamic>> getTeamMembers() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.teamMembersEndpoint),
        headers: _headers(),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load team members');
      }
    } catch (e) {
      throw Exception('Error fetching team members: $e');
    }
  }

  static Future<List<dynamic>> getReports() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.reportsEndpoint),
        headers: _headers(),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load reports');
      }
    } catch (e) {
      throw Exception('Error fetching reports: $e');
    }
  }
}