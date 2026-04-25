import 'dart:convert';
import 'package:http/http.dart' as http;

class HistoryService {
  static const String _url =
      "https://backend.trustscan.online/api/user_scans_history";

  static Future<Map<String, dynamic>> fetchHistory({required int userId}) async {
    final uri = Uri.parse(_url);
    final payload = {"user_id": userId};

    print("✅ HISTORY API HIT: $uri");
    print("📦 HISTORY PAYLOAD: $payload");

    try {
      final res = await http.post(
        uri,
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      );

      print("✅ HISTORY STATUS: ${res.statusCode}");
      print("📩 HISTORY RAW BODY: ${res.body}");

      final decoded = jsonDecode(res.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return {
        "status": false,
        "message": "Invalid history response",
        "data": [],
      };
    } catch (e) {
      print("❌ HISTORY EXCEPTION: $e");
      return {
        "status": false,
        "message": e.toString(),
        "data": [],
      };
    }
  }
}