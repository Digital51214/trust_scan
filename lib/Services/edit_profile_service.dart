// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class EditProfileService {
//   static const String _url = "https://backend.trustscan.online/api/edit_profile";
//
//   /// ✅ Returns decoded JSON (Map) on success.
//   /// ✅ Throws Exception with readable message on failure.
//   static Future<Map<String, dynamic>> editProfile({
//     required int userId,
//     required String name,
//     required String imageBase64, // can be "" if not updated
//   }) async {
//     final uri = Uri.parse(_url);
//
//     final body = {
//       "user_id": userId.toString(),
//       "name": name,
//       "image": imageBase64,
//     };
//
//     // ✅ DEBUG PRINTS (REQUEST)
//     print("🟦 EDIT PROFILE API CALLED");
//     print("➡️ URL: $_url");
//     print("➡️ BODY: {user_id: ${body["user_id"]}, name: ${body["name"]}, image: ${imageBase64.isEmpty ? "EMPTY" : "BASE64(${imageBase64.length})"}}");
//     print("➡️ HEADERS: (none)");
//
//     http.Response res;
//     try {
//       res = await http.post(uri, body: body);
//
//       // ✅ DEBUG PRINTS (RESPONSE)
//       print("✅ STATUS CODE: ${res.statusCode}");
//       print("✅ RAW RESPONSE: ${res.body}");
//
//     } catch (e) {
//       print("❌ NETWORK ERROR: $e");
//       throw Exception("Network error: $e");
//     }
//
//     Map<String, dynamic> jsonRes;
//     try {
//       jsonRes = json.decode(res.body) as Map<String, dynamic>;
//
//       // ✅ DEBUG PRINTS (DECODED JSON)
//       print("✅ JSON DECODED RESPONSE: $jsonRes");
//     } catch (e) {
//       print("❌ JSON DECODE ERROR: $e");
//       print("❌ RAW BODY (for debug): ${res.body}");
//       throw Exception("Invalid server response");
//     }
//
//     // ✅ Many APIs use 200 even for errors, so check both statusCode and json flags.
//     if (res.statusCode == 200 || res.statusCode == 201) {
//       final msg = (jsonRes["message"] ?? "").toString();
//       final successVal = jsonRes["success"];
//       final statusVal = jsonRes["status"];
//
//       final isSuccess = (successVal == true) ||
//           (statusVal == true) ||
//           (msg.toLowerCase().contains("success"));
//
//       // ✅ DEBUG PRINTS (SUCCESS CHECK)
//       print("🟨 SUCCESS CHECK:");
//       print("   success: $successVal");
//       print("   status : $statusVal");
//       print("   message: $msg");
//       print("   isSuccessComputed: $isSuccess");
//       print("   hasData: ${jsonRes["data"] != null}");
//       print("   hasUser: ${jsonRes["user"] != null}");
//
//       if (isSuccess || (jsonRes["data"] != null) || (jsonRes["user"] != null)) {
//         print("🟩 EDIT PROFILE SUCCESS ✅");
//         return jsonRes;
//       }
//
//       // fallback: maybe message contains error
//       if (msg.isNotEmpty) {
//         print("🟥 EDIT PROFILE FAILED (API MSG): $msg");
//         throw Exception(msg);
//       }
//
//       print("🟥 EDIT PROFILE FAILED: Update failed");
//       throw Exception("Update failed");
//     }
//
//     // non-200
//     final errMsg = (jsonRes["message"] ?? "Request failed").toString();
//     print("🟥 EDIT PROFILE FAILED (NON-200): ${res.statusCode} | $errMsg");
//     throw Exception(errMsg);
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditProfileService {
  static const String _url =
      "https://backend.trustscan.online/api/edit_profile";

  /// Returns decoded JSON response on success.
  /// Throws Exception with readable message on failure.
  static Future<Map<String, dynamic>> editProfile({
    required int userId,
    required String name,
    required String imageBase64,
  }) async {
    final uri = Uri.parse(_url);

    final body = {
      "user_id": userId.toString(),
      "name": name,
      "image": imageBase64,
    };

    print("━━━━━━━━━━ AI PROFILE UPDATE REQUEST ━━━━━━━━━━");
    print("Endpoint  : $_url");
    print(
      "Payload   : {user_id: ${body["user_id"]}, name: ${body["name"]}, image: ${imageBase64.isEmpty ? "EMPTY" : "BASE64(${imageBase64.length})"}}",
    );
    print("Headers   : none");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    http.Response res;
    try {
      res = await http.post(uri, body: body);

      print("━━━━━━━━━━ AI PROFILE UPDATE RESPONSE ━━━━━━━━━");
      print("Status    : ${res.statusCode}");
      print("Raw Body  : ${res.body}");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    } catch (e) {
      print("✖ NETWORK FAILURE :: $e");
      throw Exception("Network error: $e");
    }

    Map<String, dynamic> jsonRes;
    try {
      jsonRes = json.decode(res.body) as Map<String, dynamic>;

      print("━━━━━━━━━━ AI RESPONSE DECODED ━━━━━━━━━━━━━━━");
      print("Decoded   : $jsonRes");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    } catch (e) {
      print("✖ JSON DECODE FAILURE :: $e");
      print("✖ RESPONSE BODY :: ${res.body}");
      throw Exception("Invalid server response");
    }

    if (res.statusCode == 200 || res.statusCode == 201) {
      final msg = (jsonRes["message"] ?? "").toString();
      final successVal = jsonRes["success"];
      final statusVal = jsonRes["status"];

      final isSuccess = (successVal == true) ||
          (statusVal == true) ||
          (msg.toLowerCase().contains("success"));

      print("━━━━━━━━━━ AI SUCCESS ANALYSIS ━━━━━━━━━━━━━━━");
      print("success   : $successVal");
      print("status    : $statusVal");
      print("message   : $msg");
      print("resolved  : $isSuccess");
      print("hasData   : ${jsonRes["data"] != null}");
      print("hasUser   : ${jsonRes["user"] != null}");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      if (isSuccess || jsonRes["data"] != null || jsonRes["user"] != null) {
        print("✔ PROFILE UPDATE ACCEPTED");
        return jsonRes;
      }

      if (msg.isNotEmpty) {
        print("✖ PROFILE UPDATE REJECTED :: $msg");
        throw Exception(msg);
      }

      print("✖ PROFILE UPDATE REJECTED :: Update failed");
      throw Exception("Update failed");
    }

    final errMsg = (jsonRes["message"] ?? "Request failed").toString();
    print("✖ PROFILE UPDATE NON-200 :: ${res.statusCode} | $errMsg");
    throw Exception(errMsg);
  }
}