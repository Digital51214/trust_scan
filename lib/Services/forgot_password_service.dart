// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class ForgotPasswordService {
//   static const String _sendOtpUrl = "https://backend.trustscan.online/api/send_otp";
//   static const String _resendOtpUrl = "https://backend.trustscan.online/api/resend_otp";
//   static const String _resetPasswordUrl =
//       "https://backend.trustscan.online/api/reset_password";
//
//   static Future<Map<String, dynamic>> sendOtp(String email) async {
//     final uri = Uri.parse(_sendOtpUrl);
//     final payload = {"email": email};
//
//     print("✅ SEND OTP API HIT: $uri");
//     print("📦 SEND OTP PAYLOAD: $payload");
//
//     try {
//       final res = await http.post(
//         uri,
//         headers: const {
//           "Content-Type": "application/json",
//           "Accept": "application/json",
//         },
//         body: jsonEncode(payload),
//       );
//
//       print("✅ SEND OTP STATUS: ${res.statusCode}");
//       print("📩 SEND OTP RAW BODY: ${res.body}");
//
//       final decoded = jsonDecode(res.body);
//       if (decoded is Map<String, dynamic>) return decoded;
//
//       return {"success": false, "message": res.body};
//     } catch (e) {
//       print("❌ SEND OTP EXCEPTION: $e");
//       return {"success": false, "message": e.toString()};
//     }
//   }
//
//   static Future<Map<String, dynamic>> resendOtp(String email) async {
//     final uri = Uri.parse(_resendOtpUrl);
//     final payload = {"email": email};
//
//     print("✅ RESEND OTP API HIT: $uri");
//     print("📦 RESEND OTP PAYLOAD: $payload");
//
//     try {
//       final res = await http.post(
//         uri,
//         headers: const {
//           "Content-Type": "application/json",
//           "Accept": "application/json",
//         },
//         body: jsonEncode(payload),
//       );
//
//       print("✅ RESEND OTP STATUS: ${res.statusCode}");
//       print("📩 RESEND OTP RAW BODY: ${res.body}");
//
//       final decoded = jsonDecode(res.body);
//       if (decoded is Map<String, dynamic>) return decoded;
//
//       return {"success": false, "message": res.body};
//     } catch (e) {
//       print("❌ RESEND OTP EXCEPTION: $e");
//       return {"success": false, "message": e.toString()};
//     }
//   }
//
//   // ✅ UPDATED: reset_password API
//   static Future<Map<String, dynamic>> resetPassword({
//     required int userId,
//     required String newPassword,
//   }) async {
//     final uri = Uri.parse(_resetPasswordUrl);
//     final payload = {
//       "user_id": userId,
//       "new_password": newPassword,
//     };
//
//     print("✅ RESET PASSWORD API HIT: $uri");
//     print("📦 RESET PASSWORD PAYLOAD: $payload");
//
//     try {
//       final res = await http.post(
//         uri,
//         headers: const {
//           "Content-Type": "application/json",
//           "Accept": "application/json",
//         },
//         body: jsonEncode(payload),
//       );
//
//       print("✅ RESET PASSWORD STATUS: ${res.statusCode}");
//       print("📩 RESET PASSWORD RAW BODY: ${res.body}");
//
//       final decoded = jsonDecode(res.body);
//       if (decoded is Map<String, dynamic>) return decoded;
//
//       return {"success": false, "message": res.body};
//     } catch (e) {
//       print("❌ RESET PASSWORD EXCEPTION: $e");
//       return {"success": false, "message": e.toString()};
//     }
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgotPasswordService {
  static const String _sendOtpUrl =
      "https://backend.trustscan.online/api/send_otp";
  static const String _resendOtpUrl =
      "https://backend.trustscan.online/api/resend_otp";
  static const String _resetPasswordUrl =
      "https://backend.trustscan.online/api/reset_password";

  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  static Future<Map<String, dynamic>> sendOtp(String email) async {
    final uri = Uri.parse(_sendOtpUrl);
    final payload = {"email": email};

    print("━━━━━━━━━━ AI OTP DISPATCH REQUEST ━━━━━━━━━━");
    print("Endpoint  : $uri");
    print("Payload   : $payload");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    try {
      final res = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(payload),
      );

      print("━━━━━━━━━━ AI OTP DISPATCH RESPONSE ━━━━━━━━━");
      print("Status    : ${res.statusCode}");
      print("Raw Body  : ${res.body}");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;

      return {
        "success": false,
        "message": res.body,
      };
    } catch (e) {
      print("✖ AI OTP DISPATCH FAILURE :: $e");
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final uri = Uri.parse(_resendOtpUrl);
    final payload = {"email": email};

    print("━━━━━━━━━━ AI OTP RESEND REQUEST ━━━━━━━━━━━━");
    print("Endpoint  : $uri");
    print("Payload   : $payload");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    try {
      final res = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(payload),
      );

      print("━━━━━━━━━━ AI OTP RESEND RESPONSE ━━━━━━━━━━━");
      print("Status    : ${res.statusCode}");
      print("Raw Body  : ${res.body}");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;

      return {
        "success": false,
        "message": res.body,
      };
    } catch (e) {
      print("✖ AI OTP RESEND FAILURE :: $e");
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required int userId,
    required String newPassword,
  }) async {
    final uri = Uri.parse(_resetPasswordUrl);
    final payload = {
      "user_id": userId,
      "new_password": newPassword,
    };

    print("━━━━━━━━ AI PASSWORD RESET REQUEST ━━━━━━━━━");
    print("Endpoint  : $uri");
    print("Payload   : $payload");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    try {
      final res = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(payload),
      );

      print("━━━━━━━━ AI PASSWORD RESET RESPONSE ━━━━━━━━");
      print("Status    : ${res.statusCode}");
      print("Raw Body  : ${res.body}");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;

      return {
        "success": false,
        "message": res.body,
      };
    } catch (e) {
      print("✖ AI PASSWORD RESET FAILURE :: $e");
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
}