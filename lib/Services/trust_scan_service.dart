import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class TrustScanService {
  static const String _checkUrlApi =
      "https://backend.trustscan.online/api/checkUrl";

  static const String _mediaDetectApi =
      "https://backend.trustscan.online/api/media_detect";

  // ── Local suspicious keyword/domain lists ──────────────────────────────────

  static const List<String> _suspiciousTlds = [
    '.tk', '.ga', '.ml', '.cf', '.gq', '.xyz', '.top', '.click',
    '.download', '.loan', '.win', '.racing', '.online', '.site',
  ];

  static const List<String> _suspiciousKeywords = [
    'free-money', 'claim-prize', 'winner', 'congratulations',
    'you-won', 'verify-account', 'secure-login', 'bank-alert',
    'account-suspended', 'urgent', 'limited-time', 'act-now',
    'click-here', 'confirm-identity', 'password-reset',
    'paypal-secure', 'amazon-verify', 'apple-id-locked',
    'iphone-winner', 'gift-card', 'crypto-reward',
  ];

  static const List<String> _scamPhrases = [
    'you have won',
    'congratulations you',
    'claim your prize',
    'click here to claim',
    'your account has been suspended',
    'verify your account',
    'urgent action required',
    'your bank account',
    'limited time offer',
    'act now',
    'free iphone',
    'send money',
    'wire transfer',
    'nigerian prince',
    'lottery winner',
    'selected as winner',
  ];

  static const List<String> _trustedDomains = [
    'google.com', 'youtube.com', 'facebook.com', 'instagram.com',
    'twitter.com', 'x.com', 'microsoft.com', 'apple.com',
    'amazon.com', 'wikipedia.org', 'github.com', 'stackoverflow.com',
    'linkedin.com', 'reddit.com', 'netflix.com', 'spotify.com',
    'whatsapp.com', 'telegram.org', 'dropbox.com', 'adobe.com',
  ];

  // ── Local scoring engine ───────────────────────────────────────────────────

  /// Returns a local risk assessment map:
  /// { "risk_level": "LOW"|"MEDIUM"|"HIGH"|"CRITICAL",
  ///   "is_threat": bool,
  ///   "threat_types": [...],
  ///   "local_score": int }
  static Map<String, dynamic> _localAnalyze(String input) {
    final lower = input.toLowerCase();
    int riskPoints = 0;
    final List<String> threats = [];

    // 1. Check trusted domains → immediately safe
    for (final domain in _trustedDomains) {
      if (lower.contains(domain)) {
        return {
          "risk_level": "LOW",
          "is_threat": false,
          "threat_types": [],
          "local_score": 92,
          "local_note": "Trusted domain detected",
        };
      }
    }

    // 2. Suspicious TLDs
    for (final tld in _suspiciousTlds) {
      if (lower.contains(tld)) {
        riskPoints += 35;
        threats.add("Suspicious TLD ($tld)");
        break;
      }
    }

    // 3. Suspicious keywords in URL/text
    for (final kw in _suspiciousKeywords) {
      if (lower.contains(kw)) {
        riskPoints += 20;
        threats.add("Suspicious keyword: $kw");
        if (riskPoints >= 60) break; // cap early
      }
    }

    // 4. Scam phrases in text
    for (final phrase in _scamPhrases) {
      if (lower.contains(phrase)) {
        riskPoints += 30;
        threats.add("Scam phrase: \"$phrase\"");
        if (riskPoints >= 90) break;
      }
    }

    // 5. IP address as URL (very suspicious)
    final ipRegex = RegExp(r'https?://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');
    if (ipRegex.hasMatch(lower)) {
      riskPoints += 40;
      threats.add("IP address used as domain");
    }

    // 6. Multiple subdomains (e.g. secure.paypal.login.evil.com)
    final urlRegex = RegExp(r'https?://([^/\s]+)');
    final urlMatch = urlRegex.firstMatch(lower);
    if (urlMatch != null) {
      final host = urlMatch.group(1) ?? '';
      final parts = host.split('.');
      if (parts.length >= 5) {
        riskPoints += 25;
        threats.add("Excessive subdomains");
      }
    }

    // 7. Urgency words
    final urgencyWords = ['urgent', 'immediately', 'expires', 'suspended', 'blocked'];
    for (final w in urgencyWords) {
      if (lower.contains(w)) {
        riskPoints += 15;
        threats.add("Urgency language");
        break;
      }
    }

    // ── Convert points to risk level ─────────────────────────────────────────
    riskPoints = riskPoints.clamp(0, 100);

    String riskLevel;
    bool isThreat;
    int localScore;

    if (riskPoints >= 70) {
      riskLevel = "CRITICAL";
      isThreat = true;
      localScore = (15 - riskPoints ~/ 10).clamp(5, 15);
    } else if (riskPoints >= 45) {
      riskLevel = "HIGH";
      isThreat = true;
      localScore = (40 - riskPoints ~/ 5).clamp(20, 35);
    } else if (riskPoints >= 20) {
      riskLevel = "MEDIUM";
      isThreat = false;
      localScore = (75 - riskPoints).clamp(50, 65);
    } else {
      riskLevel = "LOW";
      isThreat = false;
      localScore = 85;
    }

    return {
      "risk_level": riskLevel,
      "is_threat": isThreat,
      "threat_types": threats,
      "local_score": localScore,
    };
  }

  // ── Merge API + local results ──────────────────────────────────────────────

  /// If API returns LOW for everything, override with local analysis
  static Map<String, dynamic> _mergeResults(
      Map<String, dynamic> apiResult,
      Map<String, dynamic> localResult,
      ) {
    final String apiRisk =
    (apiResult["risk_level"] ?? "LOW").toString().toUpperCase();
    final bool apiThreat = apiResult["is_threat"] == true;

    // If API already detected a threat → trust API
    if (apiThreat || apiRisk == "HIGH" || apiRisk == "CRITICAL") {
      return apiResult;
    }

    // If local analysis found threats but API said LOW → use local
    final bool localThreat = localResult["is_threat"] == true;
    final String localRisk =
    (localResult["risk_level"] ?? "LOW").toString().toUpperCase();

    if (localThreat || localRisk == "HIGH" || localRisk == "CRITICAL") {
      return {
        ...apiResult, // keep API fields (domain_age, registrar etc.)
        "risk_level": localResult["risk_level"],
        "is_threat": localResult["is_threat"],
        "threat_types": localResult["threat_types"],
        "_source": "local_override", // debug field
      };
    }

    // MEDIUM: take the worse of the two
    if (localRisk == "MEDIUM" && apiRisk == "LOW") {
      return {
        ...apiResult,
        "risk_level": "MEDIUM",
        "is_threat": false,
        "threat_types": localResult["threat_types"],
        "_source": "local_medium",
      };
    }

    // Both agree → return API result as-is
    return apiResult;
  }

  // ── Score calculator (shared logic) ───────────────────────────────────────

  static int computeTrustScore(Map<String, dynamic> result) {
    final String riskLevel =
    (result["risk_level"] ?? "LOW").toString().toUpperCase();
    final bool threat = result["is_threat"] == true;

    // If local_score was computed, use it for more precise display
    if (result.containsKey("local_score") &&
        (result["_source"] == "local_override" ||
            result["_source"] == "local_medium")) {
      return (result["local_score"] as int).clamp(0, 100);
    }

    switch (riskLevel) {
      case "LOW":
        return 90;
      case "MEDIUM":
        return 60;
      case "HIGH":
        return 25;
      case "CRITICAL":
        return 10;
      default:
        return threat ? 30 : 80;
    }
  }

  // ── Public API methods ─────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> checkUrl({
    required int userId,
    required String url,
  }) async {
    // Run local analysis immediately
    final localResult = _localAnalyze(url);

    try {
      final response = await http.post(
        Uri.parse(_checkUrlApi),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "url": url}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // Merge API + local
        return _mergeResults(data, localResult);
      } else {
        throw Exception(data["message"] ?? "API Error: ${response.statusCode}");
      }
    } catch (_) {
      // If API fails entirely, fall back to local-only result
      return {
        ...localResult,
        "_source": "local_fallback",
        "domain_age": "Unknown",
        "registrar": "Unknown",
        "created_date": "Unknown",
      };
    }
  }

  static Future<Map<String, dynamic>> detectMedia({
    required int userId,
    required File file,
  }) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse(_mediaDetectApi),
    );

    request.fields["user_id"] = userId.toString();
    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["message"] ?? "API Error: ${response.statusCode}");
    }
  }
}