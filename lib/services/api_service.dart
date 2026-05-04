import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/alert_model.dart';

class ApiService {
  static Future<List<Alert>> fetchAlerts() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.alertsEndpoint),
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
}
