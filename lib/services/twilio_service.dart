import 'dart:convert';
import 'package:http/http.dart' as http;

class TwilioService {
  /// Sends an SMS via Twilio REST API. Returns true on 200/201 responses.
  static Future<bool> sendSms({
    required String accountSid,
    required String authToken,
    required String from,
    required String to,
    required String body,
  }) async {
    if (accountSid.isEmpty || authToken.isEmpty || from.isEmpty) return false;

    final uri = Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');
    final credentials = base64Encode(utf8.encode('$accountSid:$authToken'));

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Basic $credentials',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {
              'From': from,
              'To': to,
              'Body': body,
            },
          )
          .timeout(const Duration(seconds: 15));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
