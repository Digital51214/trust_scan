import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String _url =
      "https://backend.trustscan.online/api/notifications/fetch";

  /// Fetches notifications for the given [userId].
  ///
  /// Returns a map like:
  /// {
  ///   "status": true/false,
  ///   "message": "...",
  ///   "unreadCount": 1,
  ///   "data": [ {id, user_id, title, description, status, date_added}, ... ]
  /// }
  static Future<Map<String, dynamic>> fetchNotifications(
      {required int userId}) async {
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

      print("NOTIFICATIONS STATUS CODE: ${res.statusCode}");
      print("NOTIFICATIONS BODY: ${res.body}");

      if (res.statusCode != 200) {
        return {
          "status": false,
          "message": "Notifications not found",
          "unreadCount": 0,
          "data": [],
        };
      }

      final decoded = jsonDecode(res.body);

      if (decoded is! Map) {
        return {
          "status": false,
          "message": "Invalid response format",
          "unreadCount": 0,
          "data": [],
        };
      }

      final map = Map<String, dynamic>.from(decoded);
      final success = map["success"] == true || map["status"] == true;

      final inner = map["data"];
      List<dynamic> list = [];
      int unreadCount = 0;

      if (inner is Map) {
        final innerMap = Map<String, dynamic>.from(inner);
        list = innerMap["notifications"] is List
            ? innerMap["notifications"] as List
            : [];
        unreadCount = int.tryParse("${innerMap["unread_count"] ?? 0}") ?? 0;
      } else if (inner is List) {
        // fallback in case backend ever returns a flat list
        list = inner;
        unreadCount =
            list.where((e) => (e is Map && (e["status"] == "Unread"))).length;
      }

      return {
        "status": success,
        "message": (map["message"] ?? "").toString(),
        "unreadCount": unreadCount,
        "data": list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
      };
    } catch (e) {
      print("NOTIFICATIONS ERROR: $e");

      return {
        "status": false,
        "message": e.toString(),
        "unreadCount": 0,
        "data": [],
      };
    }
  }
}