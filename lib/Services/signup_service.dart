import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupService {
  static const String _baseUrl = "https://backend.trustscan.online/api/signup";

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(_baseUrl);

    final payload = {
      "name": name,
      "email": email,
      "password": password,
    };

    print("✅ SIGNUP API HIT: $uri");
    print("📦 SIGNUP PAYLOAD: $payload");

    try {
      final res = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      );

      print("✅ SIGNUP STATUS: ${res.statusCode}");
      print("📩 SIGNUP RAW BODY: ${res.body}");

      Map<String, dynamic> data;
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        // JSON parse fail -> still return API raw body as message (not our own)
        return {
          "success": false,
          "message": res.body, // API raw response
          "data": null,
        };
      }

      // Return whatever API sends (success/message/data)
      return data;
    } catch (e) {
      // Network/exception -> cannot invent message; show exception string only
      print("❌ SIGNUP EXCEPTION: $e");
      return {
        "success": false,
        "message": e.toString(),
        "data": null,
      };
    }
  }
}
