import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  static const String _url = "https://backend.trustscan.online/api/login";

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(_url);

    final payload = {"email": email, "password": password};

    print("✅ LOGIN API HIT: $uri");
    print("📦 LOGIN PAYLOAD: $payload");

    try {
      final res = await http.post(
        uri,
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      );

      print("✅ LOGIN STATUS: ${res.statusCode}");
      print("📩 LOGIN RAW BODY: ${res.body}");

      final decoded = jsonDecode(res.body);

      if (decoded is Map<String, dynamic>) {
        // ✅ if backend did not send `success`, treat as false
        if (!decoded.containsKey("success")) {
          return {
            "success": false,
            "message": (decoded["message"] ?? res.body).toString(),
            "data": null,
          };
        }
        return decoded;
      }

      return {
        "success": false,
        "message": res.body, // api raw response
        "data": null,
      };
    } catch (e) {
      print("❌ LOGIN EXCEPTION: $e");
      return {
        "success": false,
        "message": e.toString(),
        "data": null,
      };
    }
  }
}
