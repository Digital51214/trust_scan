import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DeleteAccountService {
  static const String _deleteAccountUrl =
      "https://backend.trustscan.online/api/delete-account";

  static Future<DeleteAccountResponse> deleteAccount({
    required int userId,
  }) async {
    try {
      final uri = Uri.parse(_deleteAccountUrl);

      final Map<String, dynamic> requestBody = {
        "user_id": userId,
      };

      debugPrint("========================================");
      debugPrint("🗑️ DELETE ACCOUNT API START");
      debugPrint("➡️ URL: $uri");
      debugPrint("➡️ BODY: ${jsonEncode(requestBody)}");
      debugPrint("========================================");

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      debugPrint("========================================");
      debugPrint("⬅️ DELETE ACCOUNT API RESPONSE");
      debugPrint("⬅️ STATUS CODE: ${response.statusCode}");
      debugPrint("⬅️ BODY: ${response.body}");
      debugPrint("========================================");

      Map<String, dynamic> responseData = {};

      if (response.body.isNotEmpty) {
        responseData = jsonDecode(response.body);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = DeleteAccountResponse.fromJson(responseData);

        debugPrint("✅ DELETE ACCOUNT SUCCESS");
        debugPrint("✅ MESSAGE: ${result.message}");

        return result;
      } else {
        final errorMessage =
            responseData["message"]?.toString() ?? "Failed to delete account.";

        debugPrint("❌ DELETE ACCOUNT FAILED");
        debugPrint("❌ MESSAGE: $errorMessage");

        return DeleteAccountResponse(
          success: false,
          message: errorMessage,
        );
      }
    } catch (e) {
      debugPrint("🔥 DELETE ACCOUNT EXCEPTION");
      debugPrint("🔥 ERROR: $e");

      return DeleteAccountResponse(
        success: false,
        message: "Something went wrong. Please try again.",
      );
    }
  }
}

class DeleteAccountResponse {
  final bool success;
  final String message;

  DeleteAccountResponse({
    required this.success,
    required this.message,
  });

  factory DeleteAccountResponse.fromJson(Map<String, dynamic> json) {
    return DeleteAccountResponse(
      success: json["success"] == true,
      message: json["message"]?.toString() ?? "Account deleted successfully.",
    );
  }
}