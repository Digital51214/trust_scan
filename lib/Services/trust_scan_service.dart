import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class TrustScanService {
  static const String _checkUrlApi =
      "https://backend.trustscan.online/api/checkUrl";

  static const String _mediaDetectApi =
      "https://backend.trustscan.online/api/media_detect";

  static const List<String> _suspiciousTlds = [
    '.tk',
    '.ga',
    '.ml',
    '.cf',
    '.gq',
    '.xyz',
    '.top',
    '.click',
    '.download',
    '.loan',
    '.win',
    '.racing',
    '.online',
    '.site',
  ];

  static const List<String> _suspiciousKeywords = [
    'free-money',
    'claim-prize',
    'winner',
    'congratulations',
    'you-won',
    'verify-account',
    'secure-login',
    'bank-alert',
    'account-suspended',
    'urgent',
    'limited-time',
    'act-now',
    'click-here',
    'confirm-identity',
    'password-reset',
    'paypal-secure',
    'amazon-verify',
    'apple-id-locked',
    'iphone-winner',
    'gift-card',
    'crypto-reward',
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
    'google.com',
    'youtube.com',
    'facebook.com',
    'instagram.com',
    'twitter.com',
    'x.com',
    'microsoft.com',
    'apple.com',
    'amazon.com',
    'wikipedia.org',
    'github.com',
    'stackoverflow.com',
    'linkedin.com',
    'reddit.com',
    'netflix.com',
    'spotify.com',
    'whatsapp.com',
    'telegram.org',
    'dropbox.com',
    'adobe.com',
  ];

  static Map<String, dynamic> _localAnalyze(String input) {
    final lower = input.toLowerCase();
    int riskPoints = 0;
    final List<String> threats = [];

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

    for (final tld in _suspiciousTlds) {
      if (lower.contains(tld)) {
        riskPoints += 35;
        threats.add("Suspicious TLD ($tld)");
        break;
      }
    }

    for (final kw in _suspiciousKeywords) {
      if (lower.contains(kw)) {
        riskPoints += 20;
        threats.add("Suspicious keyword: $kw");
        if (riskPoints >= 60) break;
      }
    }

    for (final phrase in _scamPhrases) {
      if (lower.contains(phrase)) {
        riskPoints += 30;
        threats.add("Scam phrase: \"$phrase\"");
        if (riskPoints >= 90) break;
      }
    }

    final ipRegex = RegExp(r'https?://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');
    if (ipRegex.hasMatch(lower)) {
      riskPoints += 40;
      threats.add("IP address used as domain");
    }

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

    final urgencyWords = [
      'urgent',
      'immediately',
      'expires',
      'suspended',
      'blocked',
    ];

    for (final word in urgencyWords) {
      if (lower.contains(word)) {
        riskPoints += 15;
        threats.add("Urgency language");
        break;
      }
    }

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

  static Map<String, dynamic> _mergeResults(
      Map<String, dynamic> apiResult,
      Map<String, dynamic> localResult,
      ) {
    final String apiRisk =
    (apiResult["risk_level"] ?? "LOW").toString().toUpperCase();
    final bool apiThreat = apiResult["is_threat"] == true;

    if (apiThreat || apiRisk == "HIGH" || apiRisk == "CRITICAL") {
      return apiResult;
    }

    final bool localThreat = localResult["is_threat"] == true;
    final String localRisk =
    (localResult["risk_level"] ?? "LOW").toString().toUpperCase();

    if (localThreat || localRisk == "HIGH" || localRisk == "CRITICAL") {
      return {
        ...apiResult,
        "risk_level": localResult["risk_level"],
        "is_threat": localResult["is_threat"],
        "threat_types": localResult["threat_types"],
        "local_score": localResult["local_score"],
        "_source": "local_override",
      };
    }

    if (localRisk == "MEDIUM" && apiRisk == "LOW") {
      return {
        ...apiResult,
        "risk_level": "MEDIUM",
        "is_threat": false,
        "threat_types": localResult["threat_types"],
        "local_score": localResult["local_score"],
        "_source": "local_medium",
      };
    }

    return apiResult;
  }

  static int computeTrustScore(Map<String, dynamic> result) {
    final directScore = result["trust_score"] ?? result["score"];
    if (directScore != null) {
      final parsed = int.tryParse(
        directScore.toString().replaceAll("%", "").trim(),
      );
      if (parsed != null) return parsed.clamp(0, 100);
    }

    final String riskLevel =
    (result["risk_level"] ?? "LOW").toString().toUpperCase();
    final bool threat = result["is_threat"] == true;

    if (result.containsKey("local_score") &&
        (result["_source"] == "local_override" ||
            result["_source"] == "local_medium" ||
            result["_source"] == "local_fallback")) {
      final local = result["local_score"];
      if (local is int) return local.clamp(0, 100);
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

  static Map<String, dynamic> parseMediaResult(
      Map<String, dynamic> raw, {
        File? file,
      }) {
    Map<String, dynamic> det = {};

    if (raw["detection"] is Map) {
      det = Map<String, dynamic>.from(raw["detection"] as Map);
    } else if (raw["result"] is Map) {
      det = Map<String, dynamic>.from(raw["result"] as Map);
    } else if (raw["data"] is Map) {
      det = Map<String, dynamic>.from(raw["data"] as Map);
    } else {
      det = Map<String, dynamic>.from(raw);
    }

    double aiConfidence = 0.0;
    final rawConf = det["ai_confidence"] ??
        det["confidence"] ??
        det["ai_score"] ??
        det["fake_probability"] ??
        raw["ai_confidence"] ??
        raw["confidence"] ??
        raw["ai_score"];

    if (rawConf != null) {
      final confStr = rawConf.toString().replaceAll("%", "").trim();
      final parsed = double.tryParse(confStr) ?? 0.0;
      aiConfidence = parsed > 1 && parsed <= 100 ? parsed : parsed * 100;
      if (parsed > 1) aiConfidence = parsed;
    }

    bool isAiGenerated = false;
    final rawAi = det["is_ai_generated"] ??
        det["ai_generated"] ??
        det["is_fake"] ??
        raw["is_ai_generated"] ??
        raw["ai_generated"];

    if (rawAi == true ||
        rawAi == 1 ||
        rawAi.toString().toLowerCase() == "true") {
      isAiGenerated = true;
    }

    bool isDeepfake = false;
    final rawDf = det["is_deepfake"] ??
        det["deepfake"] ??
        raw["is_deepfake"] ??
        raw["deepfake"];

    if (rawDf == true ||
        rawDf == 1 ||
        rawDf.toString().toLowerCase() == "true") {
      isDeepfake = true;
    }

    String verdict =
        det["verdict"]?.toString() ?? raw["verdict"]?.toString() ?? "";

    final lowerVerdict = verdict.toLowerCase();
    if (lowerVerdict.contains("ai") ||
        lowerVerdict.contains("fake") ||
        lowerVerdict.contains("deepfake") ||
        lowerVerdict.contains("manipulated")) {
      isAiGenerated = true;
    }

    if (aiConfidence >= 50) {
      isAiGenerated = true;
    }

    if (verdict.trim().isEmpty) {
      verdict = isAiGenerated || isDeepfake ? "AI Generated" : "Human";
    }

    String generatedBy = det["generated_by"]?.toString() ??
        det["generator"]?.toString() ??
        raw["generated_by"]?.toString() ??
        raw["generator"]?.toString() ??
        "Unknown";

    int authenticityScore = 100 - aiConfidence.round();
    authenticityScore = authenticityScore.clamp(0, 100);

    String fileName = raw["file_name"]?.toString() ??
        det["file_name"]?.toString() ??
        "";

    if (fileName.isEmpty && file != null) {
      fileName = file.path.split('/').last;
    }

    final ext = fileName.split('.').last.toLowerCase();

    String fileType = raw["file_type"]?.toString() ??
        det["file_type"]?.toString() ??
        "";

    if (fileType.isEmpty || fileType == "Unknown") {
      if (["mp4", "mov", "avi", "mkv", "webm"].contains(ext)) {
        fileType = "video";
      } else if (["jpg", "jpeg", "png", "webp", "gif"].contains(ext)) {
        fileType = "image";
      } else {
        fileType = "media";
      }
    }

    return {
      "status": true,
      "detection": {
        "is_ai_generated": isAiGenerated,
        "is_deepfake": isDeepfake,
        "ai_confidence": "${aiConfidence.toStringAsFixed(1)}%",
        "verdict": verdict,
        "generated_by": generatedBy,
      },
      "file_type": fileType,
      "file_name": fileName,
      "authenticity_score": authenticityScore,
      "is_human_content": !isAiGenerated && !isDeepfake,
      "verdict": verdict,
      "ai_confidence": "${aiConfidence.toStringAsFixed(1)}%",
      "generated_by": generatedBy,
    };
  }

  static Future<Map<String, dynamic>> checkUrl({
    required int userId,
    required String url,
  }) async {
    final localResult = _localAnalyze(url);

    try {
      final response = await http
          .post(
        Uri.parse(_checkUrlApi),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "url": url,
        }),
      )
          .timeout(const Duration(seconds: 15));

      final decoded = jsonDecode(response.body);
      final data = decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded as Map);

      if (response.statusCode == 200) {
        return {
          ..._mergeResults(data, localResult),
          "url": url,
        };
      } else {
        throw Exception(data["message"] ?? "API Error: ${response.statusCode}");
      }
    } catch (e) {
      return {
        ...localResult,
        "_source": "local_fallback",
        "domain_age": "Unknown",
        "registrar": "Unknown",
        "created_date": "Unknown",
        "url": url,
      };
    }
  }

  static Future<Map<String, dynamic>> detectMedia({
    required int userId,
    required File file,
  }) async {
    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse(_mediaDetectApi),
      );

      request.fields["user_id"] = userId.toString();
      request.files.add(await http.MultipartFile.fromPath("file", file.path));

      final streamedResponse =
      await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      print("MEDIA DETECT STATUS: ${response.statusCode}");
      print("MEDIA DETECT BODY: ${response.body}");

      if (response.statusCode == 200) {
        final raw = jsonDecode(response.body);
        Map<String, dynamic> rawMap = {};

        if (raw is Map<String, dynamic>) {
          rawMap = raw;
        } else if (raw is Map) {
          rawMap = Map<String, dynamic>.from(raw);
        }

        return parseMediaResult(rawMap, file: file);
      }

      return _mediaFallback(file);
    } catch (e) {
      print("MEDIA DETECT ERROR: $e");
      return _mediaFallback(file);
    }
  }

  static Map<String, dynamic> _mediaFallback(File file) {
    final fileName = file.path.split('/').last;
    final ext = fileName.split('.').last.toLowerCase();
    final isVideo = ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext);

    return {
      "status": false,
      "detection": {
        "is_ai_generated": false,
        "is_deepfake": false,
        "ai_confidence": "0.0%",
        "verdict": "Unable to Analyze",
        "generated_by": "Unknown",
      },
      "file_type": isVideo ? "video" : "image",
      "file_name": fileName,
      "authenticity_score": 50,
      "is_human_content": true,
      "verdict": "Unable to Analyze",
      "ai_confidence": "0.0%",
      "generated_by": "Unknown",
      "_source": "local_fallback",
    };
  }
}