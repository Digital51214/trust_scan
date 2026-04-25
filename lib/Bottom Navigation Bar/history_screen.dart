import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    with WidgetsBindingObserver, RouteAware {
  VideoPlayerController? _bgVideoController;

  bool isLoading = true;
  String errorMsg = "";
  List<Map<String, dynamic>> items = [];

  bool _isVisible = false;

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

    if (route != null && route.isCurrent) {
      if (!_isVisible) {
        _isVisible = true;
      } else {
        _loadHistory();
      }
    } else {
      _isVisible = false;
    }
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
    });

    final session = SessionController.instance;
    session.loadSession();

    final int userId = session.userId.value;

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

    final ok = result["status"] == true;
    final msg = (result["message"] ?? "").toString();

    if (!ok) {
      setState(() {
        isLoading = false;
        errorMsg = msg.isEmpty ? "Failed to fetch history" : msg;
      });

      return;
    }

    final data = result["data"];

    if (data is List) {
      setState(() {
        items = data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        errorMsg = "Invalid history response";
      });
    }
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

  List _threatTypesList(Map<String, dynamic> it) {
    final data = _normalizedScan(it);
    final threatTypes = data["threat_types"] ?? it["threat_types"];

    if (threatTypes is List) return threatTypes;

    if (threatTypes is String) {
      final text = threatTypes.trim();

      if (text.isEmpty ||
          text.toLowerCase() == "no threats" ||
          text.toLowerCase() == "none" ||
          text.toLowerCase() == "[]") {
        return [];
      }

      try {
        final decoded = jsonDecode(text);
        if (decoded is List) return decoded;
      } catch (_) {}

      return [text];
    }

    return [];
  }

  String _riskLevelText(Map<String, dynamic> it) {
    final data = _normalizedScan(it);

    return (data["risk_level"] ??
        it["risk_level"] ??
        data["status"] ??
        it["status"] ??
        "")
        .toString()
        .trim()
        .toUpperCase();
  }

  bool _urlIsThreat(Map<String, dynamic> it) {
    final data = _normalizedScan(it);
    final riskLevel = _riskLevelText(it);
    final threatTypes = _threatTypesList(it);

    final threatFlag = _asBool(data["is_threat"]) ||
        _asBool(it["is_threat"]) ||
        _asBool(data["threat"]) ||
        _asBool(it["threat"]) ||
        _asBool(data["unsafe"]) ||
        _asBool(it["unsafe"]) ||
        _asBool(data["harmful"]) ||
        _asBool(it["harmful"]);

    final harmfulStatus = riskLevel == "HIGH" ||
        riskLevel == "CRITICAL" ||
        riskLevel == "UNSAFE" ||
        riskLevel == "HARMFUL" ||
        riskLevel == "MALICIOUS" ||
        riskLevel == "DANGEROUS";

    return threatFlag || harmfulStatus || threatTypes.isNotEmpty;
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

    final scanResult = (it["scan_result"] ?? "").toString().toLowerCase();

    if (scanResult.contains("ai_confidence") ||
        scanResult.contains("deepfake") ||
        scanResult.contains("is_ai_generated") ||
        scanResult.contains("generated_by")) {
      if (fileName.contains("video") || fileType.contains("video")) {
        return "video";
      }

      return "image";
    }

    if (url.isNotEmpty && (url.startsWith("http") || url.contains("."))) {
      return "url";
    }

    return "url";
  }

  int _historyScore(Map<String, dynamic> it) {
    final type = _scanType(it);
    final data = _normalizedScan(it);
    final det = _detectionMap(it);

    final directScore = data["authenticity_score"] ??
        it["authenticity_score"] ??
        data["trust_score"] ??
        it["trust_score"] ??
        data["score"] ??
        it["score"];

    if (directScore != null) {
      final parsed = int.tryParse(
        directScore.toString().replaceAll("%", "").trim(),
      );

      if (parsed != null) {
        if (type == "url" && _urlIsThreat(it) && parsed >= 70) {
          return 30;
        }

        return parsed.clamp(0, 100);
      }
    }

    if (type == "image" || type == "video") {
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

    final riskLevel = _riskLevelText(it);
    final isThreat = _urlIsThreat(it);

    switch (riskLevel) {
      case "LOW":
      case "SAFE":
      case "CLEAN":
        return isThreat ? 30 : 90;

      case "MEDIUM":
      case "SUSPICIOUS":
        return 60;

      case "HIGH":
      case "UNSAFE":
      case "HARMFUL":
      case "MALICIOUS":
      case "DANGEROUS":
        return 25;

      case "CRITICAL":
        return 10;

      default:
        return isThreat ? 30 : 80;
    }
  }

  bool _isHighRisk(Map<String, dynamic> it) {
    final type = _scanType(it);
    final score = _historyScore(it);

    if (type == "url") {
      return score < 70 || _urlIsThreat(it);
    }

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

    if (highRisk) {
      return type == "url"
          ? Icons.warning_rounded
          : Icons.smart_display_rounded;
    }

    return type == "video"
        ? Icons.videocam_rounded
        : type == "image"
        ? Icons.image_rounded
        : Icons.verified_user_rounded;
  }

  String _statusText(Map<String, dynamic> it) {
    final type = _scanType(it);
    final score = _historyScore(it);
    final highRisk = _isHighRisk(it);

    if (type == "url") {
      if (_urlIsThreat(it)) {
        return score >= 40 ? "Suspicious" : "High Risk";
      }

      if (score >= 70) return "Safe";
      if (score >= 40) return "Suspicious";
      return "High Risk";
    }

    if (!highRisk && score >= 50) return "Authentic";
    return "AI / Suspicious";
  }

  Color _statusColor(Map<String, dynamic> it) {
    final score = _historyScore(it);
    final highRisk = _isHighRisk(it);

    if (highRisk) return const Color(0xFFE85B5B);
    if (score >= 70) return const Color(0xFF3DDC84);
    return const Color(0xFF2CC7FF);
  }

  Color _statusBg(Map<String, dynamic> it) {
    final highRisk = _isHighRisk(it);
    return highRisk ? const Color(0xFF3A2A3A) : const Color(0xFF10344B);
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
          _videoBackground(),
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
            child: VideoBackground(),
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
    final highRisk = _isHighRisk(it);
    final score = _historyScore(it);

    final iconBg =
    highRisk ? const Color(0xFF1B2F47) : const Color(0xFF102E45);
    final iconColor =
    highRisk ? const Color(0xFFE85B5B) : const Color(0xFF2CC7FF);

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
      borderColor: highRisk ? const Color(0xFFE85B5B) : cyan,
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