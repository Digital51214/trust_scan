import 'dart:convert';
import 'package:http/http.dart' as http;

class HistoryService {
  static const String _url =
      "https://backend.trustscan.online/api/user_scans_history";

  static Future<Map<String, dynamic>> fetchHistory({required int userId}) async {
    try {
      final res = await http.post(
        Uri.parse(_url),
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "user_id": userId,
        }),
      );

      print("HISTORY STATUS CODE: ${res.statusCode}");
      print("HISTORY BODY: ${res.body}");

      if (res.statusCode != 200) {
        return {
          "status": false,
          "message": "Server error: ${res.statusCode}",
          "data": [],
        };
      }

      final decoded = jsonDecode(res.body);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return {
        "status": false,
        "message": "Invalid response format",
        "data": [],
      };
    } catch (e) {
      print("HISTORY ERROR: $e");

      return {
        "status": false,
        "message": e.toString(),
        "data": [],
      };
    }
  }
}