import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/alert_model.dart';
import 'app_state.dart';

class ApiService {
  static Future<List<Alert>> fetchAlerts() async {
    try {
      final token = AppState.instance.backendAuthToken;
      final response = await http.get(
        Uri.parse(AppConstants.alertsEndpoint),
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
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
      final token = AppState.instance.backendAuthToken;
      final response = await http.get(
        Uri.parse(AppConstants.threatsEndpoint),
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
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

  static Future<List<Alert>> fetchThreatFeed() async {
    try {
      final raw = await fetchThreats();
      final list = raw is List ? raw : <dynamic>[];
      return list
          .whereType<Map<String, dynamic>>()
          .map(Alert.fromThreatJson)
          .toList();
    } catch (e) {
      throw Exception('Error fetching threat feed: $e');
    }
  }

  static Future<List<Alert>> fetchGeoThreatFeed() async {
    try {
      return await fetchThreatFeed();
    } catch (e) {
      throw Exception('Error fetching geo threat feed: $e');
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
