import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:social_saver/Bottom%20Navigation%20Bar/video_background.dart';
import 'package:video_player/video_player.dart';

import 'package:social_saver/services/history_service.dart';
import 'package:social_saver/session/session_controller.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with WidgetsBindingObserver {
  VideoPlayerController? _bgVideoController;

  bool isLoading = true;
  String errorMsg = "";
  List<Map<String, dynamic>> items = [];

  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _bgVideoController =
        VideoPlayerController.asset("assets/vedio/settings.mp4");

    _bgVideoController!.initialize().then((_) {
      if (!mounted) return;

      _bgVideoController!
        ..setLooping(true)
        ..setVolume(0)
        ..play();

      setState(() {});
    });

    _loadHistory();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bgVideoController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isVisible) {
      _loadHistory();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    _isVisible = route?.isCurrent ?? true;
  }

  Widget _videoBackground() {
    final controller = _bgVideoController;

    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.expand();
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMsg = "";
      items = [];
    });

    final session = SessionController.instance;
    session.loadSession();

    final int userId = session.userId.value;

    debugPrint("HISTORY USER ID: $userId");

    if (userId <= 0) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMsg = "User not logged in";
      });
      return;
    }

    final result = await HistoryService.fetchHistory(userId: userId);

    if (!mounted) return;

    debugPrint("HISTORY RESULT: $result");

    final ok = result["status"] == true;
    final data = result["data"];

    if (!ok) {
      setState(() {
        isLoading = false;
        errorMsg = (result["message"] ?? "Failed to fetch history").toString();
      });
      return;
    }

    if (data is! List) {
      setState(() {
        isLoading = false;
        errorMsg = "History data not found";
      });
      return;
    }

    final loadedItems = data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    debugPrint("HISTORY ITEMS LENGTH: ${loadedItems.length}");

    setState(() {
      items = loadedItems;
      isLoading = false;
    });
  }

  Map<String, dynamic> _normalizedScan(Map<String, dynamic> it) {
    dynamic raw = it["scan_result"] ??
        it["result"] ??
        it["detection"] ??
        it["data"] ??
        it["response"];

    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {
        return it;
      }
    }

    if (raw is Map<String, dynamic>) {
      return {
        ...it,
        ...raw,
      };
    }

    if (raw is Map) {
      return {
        ...it,
        ...Map<String, dynamic>.from(raw),
      };
    }

    return it;
  }

  Map<String, dynamic> _detectionMap(Map<String, dynamic> it) {
    final data = _normalizedScan(it);

    final det = data["detection"];
    if (det is Map<String, dynamic>) return det;
    if (det is Map) return Map<String, dynamic>.from(det);

    final result = data["result"];
    if (result is Map<String, dynamic>) return result;
    if (result is Map) return Map<String, dynamic>.from(result);

    return data;
  }

  bool _asBool(dynamic value) {
    if (value == true || value == 1) return true;
    if (value == false || value == 0 || value == null) return false;

    final text = value.toString().trim().toLowerCase();

    return text == "true" ||
        text == "1" ||
        text == "yes" ||
        text == "y" ||
        text == "threat" ||
        text == "unsafe" ||
        text == "harmful" ||
        text == "malicious" ||
        text == "dangerous";
  }

  String _scanText(Map<String, dynamic> it) {
    final data = _normalizedScan(it);

    return [
      it["scan_result"],
      data["scan_result"],
      it["risk_level"],
      data["risk_level"],
      it["is_threat"],
      data["is_threat"],
      it["threat_types"],
      data["threat_types"],
      it["status"],
      data["status"],
      it["message"],
      data["message"],
    ].where((e) => e != null).join(" ").toLowerCase();
  }

  String _scanType(Map<String, dynamic> it) {
    final data = _normalizedScan(it);

    final fileType = (it["file_type"] ??
        data["file_type"] ??
        data["media_type"] ??
        data["type"] ??
        "")
        .toString()
        .toLowerCase();

    final fileName = (it["file_name"] ??
        data["file_name"] ??
        data["filename"] ??
        data["name"] ??
        "")
        .toString()
        .toLowerCase();

    final url = (it["url"] ?? data["url"] ?? data["link"] ?? "").toString();

    if (fileType.contains("video") ||
        fileName.endsWith(".mp4") ||
        fileName.endsWith(".mov") ||
        fileName.endsWith(".avi") ||
        fileName.endsWith(".mkv") ||
        fileName.endsWith(".webm")) {
      return "video";
    }

    if (fileType.contains("image") ||
        fileType.contains("photo") ||
        fileName.endsWith(".jpg") ||
        fileName.endsWith(".jpeg") ||
        fileName.endsWith(".png") ||
        fileName.endsWith(".webp") ||
        fileName.endsWith(".gif")) {
      return "image";
    }

    if (url.isNotEmpty && (url.startsWith("http") || url.contains("."))) {
      return "url";
    }

    return "url";
  }

  int _extractRiskScore(Map<String, dynamic> it) {
    final text = _scanText(it);

    final match = RegExp(
      r'risk\s*score\s*:\s*(\d+)',
      caseSensitive: false,
    ).firstMatch(text);

    if (match != null) {
      return int.tryParse(match.group(1) ?? "") ?? 0;
    }

    return 0;
  }

  int _localUrlScore(String url) {
    final lower = url.toLowerCase();

    int riskPoints = 0;

    const suspiciousTlds = [
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

    const suspiciousKeywords = [
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

    const scamPhrases = [
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

    const trustedDomains = [
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

    for (final domain in trustedDomains) {
      if (lower.contains(domain)) {
        return 92;
      }
    }

    for (final tld in suspiciousTlds) {
      if (lower.contains(tld)) {
        riskPoints += 35;
        break;
      }
    }

    for (final keyword in suspiciousKeywords) {
      if (lower.contains(keyword)) {
        riskPoints += 20;
        if (riskPoints >= 80) break;
      }
    }

    for (final phrase in scamPhrases) {
      if (lower.contains(phrase)) {
        riskPoints += 30;
        if (riskPoints >= 90) break;
      }
    }

    final ipRegex = RegExp(r'https?://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');
    if (ipRegex.hasMatch(lower)) {
      riskPoints += 40;
    }

    final urlRegex = RegExp(r'https?://([^/\s]+)');
    final urlMatch = urlRegex.firstMatch(lower);

    if (urlMatch != null) {
      final host = urlMatch.group(1) ?? '';
      final parts = host.split('.');

      if (parts.length >= 5) {
        riskPoints += 25;
      }
    }

    const urgencyWords = [
      'urgent',
      'immediately',
      'expires',
      'suspended',
      'blocked',
    ];

    for (final word in urgencyWords) {
      if (lower.contains(word)) {
        riskPoints += 15;
        break;
      }
    }

    riskPoints = riskPoints.clamp(0, 100);

    if (riskPoints >= 70) return 10;
    if (riskPoints >= 45) return 25;
    if (riskPoints >= 20) return 60;

    return 90;
  }

  int _historyScore(Map<String, dynamic> it) {
    final type = _scanType(it);

    if (type == "image" || type == "video") {
      final data = _normalizedScan(it);
      final det = _detectionMap(it);

      final directScore = data["authenticity_score"] ??
          it["authenticity_score"] ??
          data["score"] ??
          it["score"];

      if (directScore != null) {
        final parsed = int.tryParse(
          directScore.toString().replaceAll("%", "").trim(),
        );

        if (parsed != null) return parsed.clamp(0, 100);
      }

      final rawConf = det["ai_confidence"] ??
          det["confidence"] ??
          det["ai_score"] ??
          data["ai_confidence"] ??
          data["confidence"];

      final conf = double.tryParse(
        rawConf.toString().replaceAll("%", "").trim(),
      ) ??
          0.0;

      return (100 - conf).round().clamp(0, 100);
    }

    final url = (it["url"] ?? "").toString();

    if (url.isNotEmpty) {
      final localScore = _localUrlScore(url);

      if (localScore < 70) {
        return localScore;
      }
    }

    final text = _scanText(it)
        .toLowerCase()
        .replaceAll("\n", " ")
        .replaceAll(RegExp(r'\s+'), " ")
        .trim();

    final status = (it["status"] ?? "").toString().toLowerCase().trim();

    final riskScore = _extractRiskScore(it);

    if (riskScore > 0) {
      if (riskScore >= 70) return 25;
      if (riskScore >= 40) return 60;
      return 90;
    }

    if (text.contains("risk level: critical") ||
        text.contains("risk level critical") ||
        text.contains("risk_level: critical") ||
        text.contains("critical") ||
        text.contains("risk level: high") ||
        text.contains("risk level high") ||
        text.contains("risk_level: high") ||
        text.contains("phishing: 1") ||
        text.contains("malicious") ||
        text.contains("dangerous") ||
        text.contains("unsafe")) {
      return 20;
    }

    if (text.contains("risk level: medium") ||
        text.contains("risk level medium") ||
        text.contains("risk_level: medium") ||
        text.contains("medium") ||
        text.contains("suspicious") ||
        text.contains("suspecious")) {
      return 55;
    }

    if (status == "malicious" ||
        status == "unsafe" ||
        status == "dangerous" ||
        status == "threat") {
      return 20;
    }

    if (status == "safe" || status == "clean") {
      return 90;
    }

    if (text.contains("risk level: low") ||
        text.contains("risk level low") ||
        text.contains("risk_level: low") ||
        text.contains("low") ||
        text.contains("safe") ||
        text.contains("clean") ||
        text.contains("no threats detected") ||
        text.contains("no threats")) {
      return 90;
    }

    return 80;
  }

  bool _isHighRisk(Map<String, dynamic> it) {
    final type = _scanType(it);
    final score = _historyScore(it);

    if (type == "url") return score < 40;

    final data = _normalizedScan(it);
    final det = _detectionMap(it);

    final verdict =
    (det["verdict"] ?? data["verdict"] ?? "").toString().toLowerCase();

    final isAi = _asBool(det["is_ai_generated"]) ||
        _asBool(data["is_ai_generated"]) ||
        verdict.contains("ai") ||
        verdict.contains("fake") ||
        verdict.contains("deepfake") ||
        verdict.contains("manipulated");

    final isDeepfake =
        _asBool(det["is_deepfake"]) || _asBool(data["is_deepfake"]);

    return score < 50 || isAi || isDeepfake;
  }

  String _statusText(Map<String, dynamic> it) {
    final type = _scanType(it);
    final score = _historyScore(it);

    if (type == "url") {
      if (score >= 70) return "Safe";
      if (score >= 40) return "Suspicious";
      return "High Risk";
    }

    final highRisk = _isHighRisk(it);
    if (!highRisk && score >= 50) return "Authentic";
    return "AI / Suspicious";
  }

  Color _statusColor(Map<String, dynamic> it) {
    final score = _historyScore(it);

    if (score >= 70) return const Color(0xFF3DDC84);
    if (score >= 40) return const Color(0xFFFFC107);
    return const Color(0xFFFF5B5B);
  }

  Color _statusBg(Map<String, dynamic> it) {
    final score = _historyScore(it);

    if (score >= 70) {
      return const Color(0xFF3DDC84).withOpacity(0.12);
    }

    if (score >= 40) {
      return const Color(0xFFFFC107).withOpacity(0.12);
    }

    return const Color(0xFFFF5B5B).withOpacity(0.12);
  }

  String _cardTitle(Map<String, dynamic> it) {
    switch (_scanType(it)) {
      case "video":
        return "AI Video Analysis";
      case "image":
        return "AI Image Analysis";
      default:
        return "AI Link Scan";
    }
  }

  String _cardSubtitle(Map<String, dynamic> it) {
    final type = _scanType(it);
    final data = _normalizedScan(it);

    if (type == "video" || type == "image") {
      final fileName = (it["file_name"] ??
          data["file_name"] ??
          data["filename"] ??
          data["name"] ??
          "")
          .toString();

      return fileName.isNotEmpty
          ? fileName
          : "Uploaded ${type == "video" ? "Video" : "Image"}";
    }

    final url = (it["url"] ?? data["url"] ?? data["link"] ?? "").toString();

    return url.isNotEmpty ? url : "Scanned URL";
  }

  String _actionLabel(Map<String, dynamic> it) {
    switch (_scanType(it)) {
      case "video":
        return "Video Scan";
      case "image":
        return "Image Scan";
      default:
        return "Link Scan";
    }
  }

  IconData _cardIcon(Map<String, dynamic> it, bool highRisk) {
    final type = _scanType(it);
    final score = _historyScore(it);

    if (type == "video") {
      if (score >= 70) return Icons.videocam_rounded;           // green – authentic video
      if (score >= 40) return Icons.video_call_rounded;         // yellow – suspicious video
      return Icons.videocam_off_rounded;                        // red – fake/AI video
    }

    if (type == "image") {
      if (score >= 70) return Icons.image_rounded;              // green – authentic image
      if (score >= 40) return Icons.image_search_rounded;       // yellow – suspicious image
      return Icons.hide_image_rounded;                          // red – fake/AI image
    }

    // URL / Link
    if (score >= 70) return Icons.verified_user_rounded;        // green – safe link
    if (score >= 40) return Icons.gpp_maybe_rounded;            // yellow – suspicious link
    return Icons.gpp_bad_rounded;                               // red – dangerous link
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF061B2B);
    const cyan = Color(0xFF2CC7FF);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(

        fit: StackFit.expand,
        children: [
          Positioned.fill(child: VideoBackground()),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0D5E7D).withOpacity(0.65),
                  bg.withOpacity(0.70),
                  const Color(0xFF020A14).withOpacity(0.82),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 1.2,
                colors: [
                  const Color(0xFF2CC7FF).withOpacity(0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "History Scan Intelligence",
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _loadHistory,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cyan.withOpacity(0.20),
                            ),
                          ),
                          child: isLoading
                              ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(cyan),
                            ),
                          )
                              : const Icon(
                            Icons.refresh_rounded,
                            color: cyan,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: const Color(0xFF2CC7FF).withOpacity(0.20),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2CC7FF).withOpacity(0.08),
                          blurRadius: 14,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF2CC7FF),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Search scanned activity...",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: RefreshIndicator(
                    color: cyan,
                    backgroundColor: const Color(0xFF0A2235),
                    onRefresh: _loadHistory,
                    child: _buildBody(cyan),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(Color cyan) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2CC7FF)),
        ),
      );
    }

    if (errorMsg.isNotEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.wifi_off_rounded,
            color: Colors.white.withOpacity(0.4),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            errorMsg,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              onTap: _loadHistory,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2CC7FF),
                      Color(0xFF0E7FBF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Retry",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.history_rounded,
            color: Colors.white.withOpacity(0.25),
            size: 48,
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              "No scans yet",
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              "Scan a link, image or video\nto see results here",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.40),
                fontSize: 13,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) => _buildCard(items[i], cyan),
    );
  }

  Widget _buildCard(Map<String, dynamic> it, Color cyan) {
    final score = _historyScore(it);
    final highRisk = score < 40;

    final iconBg =
    highRisk ? const Color(0xFF1B2F47) : const Color(0xFF102E45);
    final iconColor = score >= 70
        ? const Color(0xFF3DDC84)   // green  – safe / authentic
        : score >= 40
        ? const Color(0xFFFFC107)   // yellow – suspicious
        : const Color(0xFFFF5B5B); // red    – high risk

    final tagText = _statusText(it);
    final tagBg = _statusBg(it);
    final tagTextColor = _statusColor(it);

    final createdAt =
    (it["created_at"] ?? it["createdAt"] ?? it["date"] ?? it["time"] ?? "")
        .toString();

    return _HistoryCard(
      iconBg: iconBg,
      icon: _cardIcon(it, highRisk),
      iconColor: iconColor,
      title: _cardTitle(it),
      subtitle: _cardSubtitle(it),
      time: createdAt,
      action: "${_actionLabel(it)} • $score%",
      tagText: tagText,
      tagBg: tagBg,
      tagTextColor: tagTextColor,
      borderColor: tagTextColor,
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.action,
    required this.tagText,
    required this.tagBg,
    required this.tagTextColor,
    required this.borderColor,
  });

  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final String action;
  final String tagText;
  final Color tagBg;
  final Color tagTextColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF0A2235).withOpacity(0.55),
        border: Border.all(
          color: borderColor.withOpacity(0.7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.08),
            blurRadius: 18,
            spreadRadius: 0.5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.18),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: tagTextColor.withOpacity(0.18),
                        ),
                      ),
                      child: Text(
                        tagText,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: tagTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        time,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.55),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      action,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}