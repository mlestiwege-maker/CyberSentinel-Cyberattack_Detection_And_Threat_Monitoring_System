import 'dart:convert';
import 'dart:io';

class AppStorage {
  AppStorage._();

  static Future<File> _stateFile() async {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? Directory.current.path;
    final directory = Directory('$home/.cybersentinel');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}/state.json');
  }

  static Future<Map<String, dynamic>> readState() async {
    try {
      final file = await _stateFile();
      if (!await file.exists()) {
        return {};
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return {};
      }

      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded);
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return {};
    }

    return {};
  }

  static Future<void> writeState(Map<String, dynamic> state) async {
    final file = await _stateFile();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(state));
  }
}