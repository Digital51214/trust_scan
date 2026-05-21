import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:social_saver/Bottom%20Navigation%20Bar/video_background.dart';

import 'package:social_saver/services/history_service.dart';
import 'package:social_saver/session/session_controller.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with WidgetsBindingObserver {
  bool isLoading = true;
  String errorMsg = "";
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];

  // ── Search ──
  final _searchCtrl = TextEditingController();
  bool _searchActive = false;
  String _searchQuery = "";

  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchCtrl.addListener(_onSearchChanged);
    _loadHistory();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
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

  // ── Search logic ──────────────────────────────────────────────
  void _onSearchChanged() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _searchQuery = q;
      filteredItems = _filterItems(q);
    });
  }

  List<Map<String, dynamic>> _filterItems(String q) {
    if (q.isEmpty) return List.from(items);

    return items.where((it) {
      final title = _cardTitle(it).toLowerCase();
      final subtitle = _cardSubtitle(it).toLowerCase();
      final type = _scanType(it).toLowerCase();
      final status = _statusText(it).toLowerCase();
      final score = _historyScore(it).toString();
      final date = (it["created_at"] ??
          it["createdAt"] ??
          it["date"] ??
          it["time"] ??
          "")
          .toString()
          .toLowerCase();
      final url =
      (it["url"] ?? "").toString().toLowerCase();
      final fileName = (it["file_name"] ??
          it["filename"] ??
          it["name"] ??
          "")
          .toString()
          .toLowerCase();

      return title.contains(q) ||
          subtitle.contains(q) ||
          type.contains(q) ||
          status.contains(q) ||
          score.contains(q) ||
          date.contains(q) ||
          url.contains(q) ||
          fileName.contains(q);
    }).toList();
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() {
      _searchQuery = "";
      _searchActive = false;
      filteredItems = List.from(items);
    });
  }

  // ── Load history ──────────────────────────────────────────────
  Future<void> _loadHistory() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMsg = "";
      items = [];
      filteredItems = [];
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
    final data = result["data"];

    if (!ok) {
      setState(() {
        isLoading = false;
        errorMsg =
            (result["message"] ?? "Failed to fetch history").toString();
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

    final loaded = data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    setState(() {
      items = loaded;
      filteredItems = _filterItems(_searchQuery); // keep active search
      isLoading = false;
    });
  }

  // ── Data helpers ──────────────────────────────────────────────
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

    if (raw is Map<String, dynamic>) return {...it, ...raw};
    if (raw is Map) return {...it, ...Map<String, dynamic>.from(raw)};
    return it;
  }

  Map<String, dynamic> _detectionMap(Map<String, dynamic> it) {
    final data = _normalizedScan(it);
    final det = data["detection"];
    if (det is Map<String, dynamic>) return det;
    if (det is Map) return Map<String, dynamic>.from(det);
    final res = data["result"];
    if (res is Map<String, dynamic>) return res;
    if (res is Map) return Map<String, dynamic>.from(res);
    return data;
  }

  bool _asBool(dynamic value) {
    if (value == true || value == 1) return true;
    if (value == false || value == 0 || value == null) return false;
    final text = value.toString().trim().toLowerCase();
    return text == "true" ||
        text == "1" ||
        text == "yes" ||
        text == "threat" ||
        text == "unsafe" ||
        text == "harmful" ||
        text == "malicious" ||
        text == "dangerous";
  }

  String _scanText(Map<String, dynamic> it) {
    final data = _normalizedScan(it);
    return [
      it["scan_result"], data["scan_result"],
      it["risk_level"], data["risk_level"],
      it["is_threat"], data["is_threat"],
      it["threat_types"], data["threat_types"],
      it["status"], data["status"],
      it["message"], data["message"],
    ].where((e) => e != null).join(" ").toLowerCase();
  }

  String _scanType(Map<String, dynamic> it) {
    final data = _normalizedScan(it);
    final fileType = (it["file_type"] ?? data["file_type"] ??
        data["media_type"] ?? data["type"] ?? "")
        .toString().toLowerCase();
    final fileName = (it["file_name"] ?? data["file_name"] ??
        data["filename"] ?? data["name"] ?? "")
        .toString().toLowerCase();
    final url = (it["url"] ?? data["url"] ?? data["link"] ?? "").toString();

    if (fileType.contains("video") || fileName.endsWith(".mp4") ||
        fileName.endsWith(".mov") || fileName.endsWith(".avi") ||
        fileName.endsWith(".mkv") || fileName.endsWith(".webm")) return "video";

    if (fileType.contains("image") || fileType.contains("photo") ||
        fileName.endsWith(".jpg") || fileName.endsWith(".jpeg") ||
        fileName.endsWith(".png") || fileName.endsWith(".webp") ||
        fileName.endsWith(".gif")) return "image";

    if (url.isNotEmpty && (url.startsWith("http") || url.contains("."))) {
      return "url";
    }
    return "url";
  }

  int _extractRiskScore(Map<String, dynamic> it) {
    final text = _scanText(it);
    final match = RegExp(r'risk\s*score\s*:\s*(\d+)',
        caseSensitive: false)
        .firstMatch(text);
    if (match != null) return int.tryParse(match.group(1) ?? "") ?? 0;
    return 0;
  }

  int _localUrlScore(String url) {
    final lower = url.toLowerCase();
    int riskPoints = 0;

    const trustedDomains = [
      'google.com', 'youtube.com', 'facebook.com', 'instagram.com',
      'twitter.com', 'x.com', 'microsoft.com', 'apple.com', 'amazon.com',
      'wikipedia.org', 'github.com', 'stackoverflow.com', 'linkedin.com',
      'reddit.com', 'netflix.com', 'spotify.com', 'whatsapp.com',
      'telegram.org', 'dropbox.com', 'adobe.com',
    ];
    for (final d in trustedDomains) {
      if (lower.contains(d)) return 92;
    }

    const suspiciousTlds = ['.tk','.ga','.ml','.cf','.gq','.xyz','.top',
      '.click','.download','.loan','.win','.racing','.online','.site'];
    for (final tld in suspiciousTlds) {
      if (lower.contains(tld)) { riskPoints += 35; break; }
    }

    const suspiciousKeywords = ['free-money','claim-prize','winner',
      'congratulations','you-won','verify-account','secure-login',
      'bank-alert','account-suspended','urgent','limited-time','act-now',
      'click-here','confirm-identity','password-reset','paypal-secure',
      'amazon-verify','apple-id-locked','iphone-winner','gift-card',
      'crypto-reward'];
    for (final kw in suspiciousKeywords) {
      if (lower.contains(kw)) {
        riskPoints += 20;
        if (riskPoints >= 80) break;
      }
    }

    const scamPhrases = ['you have won','congratulations you','claim your prize',
      'click here to claim','your account has been suspended','verify your account',
      'urgent action required','your bank account','limited time offer','act now',
      'free iphone','send money','wire transfer','nigerian prince','lottery winner',
      'selected as winner'];
    for (final p in scamPhrases) {
      if (lower.contains(p)) {
        riskPoints += 30;
        if (riskPoints >= 90) break;
      }
    }

    final ipRegex = RegExp(r'https?://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');
    if (ipRegex.hasMatch(lower)) riskPoints += 40;

    final urlMatch = RegExp(r'https?://([^/\s]+)').firstMatch(lower);
    if (urlMatch != null) {
      final parts = (urlMatch.group(1) ?? '').split('.');
      if (parts.length >= 5) riskPoints += 25;
    }

    const urgencyWords = ['urgent','immediately','expires','suspended','blocked'];
    for (final w in urgencyWords) {
      if (lower.contains(w)) { riskPoints += 15; break; }
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
          it["authenticity_score"] ?? data["score"] ?? it["score"];
      if (directScore != null) {
        final parsed = int.tryParse(
            directScore.toString().replaceAll("%", "").trim());
        if (parsed != null) return parsed.clamp(0, 100);
      }
      final rawConf = det["ai_confidence"] ?? det["confidence"] ??
          det["ai_score"] ?? data["ai_confidence"] ?? data["confidence"];
      final conf = double.tryParse(
          rawConf.toString().replaceAll("%", "").trim()) ??
          0.0;
      return (100 - conf).round().clamp(0, 100);
    }

    final url = (it["url"] ?? "").toString();
    if (url.isNotEmpty) {
      final localScore = _localUrlScore(url);
      if (localScore < 70) return localScore;
    }

    final text = _scanText(it)
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

    if (text.contains("critical") || text.contains("risk level: high") ||
        text.contains("phishing: 1") || text.contains("malicious") ||
        text.contains("dangerous") || text.contains("unsafe")) return 20;

    if (text.contains("medium") || text.contains("suspicious") ||
        text.contains("suspecious")) return 55;

    if (status == "malicious" || status == "unsafe" ||
        status == "dangerous" || status == "threat") return 20;

    if (status == "safe" || status == "clean") return 90;

    if (text.contains("risk level: low") || text.contains("low") ||
        text.contains("safe") || text.contains("clean") ||
        text.contains("no threats")) return 90;

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
        verdict.contains("ai") || verdict.contains("fake") ||
        verdict.contains("deepfake") || verdict.contains("manipulated");
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
    if (score >= 70) return const Color(0xFF3DDC84).withOpacity(0.12);
    if (score >= 40) return const Color(0xFFFFC107).withOpacity(0.12);
    return const Color(0xFFFF5B5B).withOpacity(0.12);
  }

  String _cardTitle(Map<String, dynamic> it) {
    switch (_scanType(it)) {
      case "video": return "AI Video Analysis";
      case "image": return "AI Image Analysis";
      default: return "AI Link Scan";
    }
  }

  String _cardSubtitle(Map<String, dynamic> it) {
    final type = _scanType(it);
    final data = _normalizedScan(it);
    if (type == "video" || type == "image") {
      final fileName = (it["file_name"] ?? data["file_name"] ??
          data["filename"] ?? data["name"] ?? "").toString();
      return fileName.isNotEmpty
          ? fileName
          : "Uploaded ${type == "video" ? "Video" : "Image"}";
    }
    final url = (it["url"] ?? data["url"] ?? data["link"] ?? "").toString();
    return url.isNotEmpty ? url : "Scanned URL";
  }

  String _actionLabel(Map<String, dynamic> it) {
    switch (_scanType(it)) {
      case "video": return "Video Scan";
      case "image": return "Image Scan";
      default: return "Link Scan";
    }
  }

  IconData _cardIcon(Map<String, dynamic> it, bool highRisk) {
    final type = _scanType(it);
    final score = _historyScore(it);
    if (type == "video") {
      if (score >= 70) return Icons.videocam_rounded;
      if (score >= 40) return Icons.video_call_rounded;
      return Icons.videocam_off_rounded;
    }
    if (type == "image") {
      if (score >= 70) return Icons.image_rounded;
      if (score >= 40) return Icons.image_search_rounded;
      return Icons.hide_image_rounded;
    }
    if (score >= 70) return Icons.verified_user_rounded;
    if (score >= 40) return Icons.gpp_maybe_rounded;
    return Icons.gpp_bad_rounded;
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF061B2B);
    const cyan = Color(0xFF2CC7FF);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // overlays only — VideoBackground is in BottomNavScreen
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
                  cyan.withOpacity(0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
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
                                color: cyan.withOpacity(0.20)),
                          ),
                          child: isLoading
                              ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                              AlwaysStoppedAnimation(cyan),
                            ),
                          )
                              : const Icon(Icons.refresh_rounded,
                              color: cyan, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Search bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: _searchActive
                            ? cyan.withOpacity(0.55)
                            : cyan.withOpacity(0.20),
                        width: _searchActive ? 1.3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cyan.withOpacity(
                              _searchActive ? 0.14 : 0.06),
                          blurRadius: 14,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: _searchActive
                              ? cyan
                              : cyan.withOpacity(0.6),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Focus(
                            onFocusChange: (hasFocus) =>
                                setState(() => _searchActive = hasFocus),
                            child: TextField(
                              controller: _searchCtrl,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                              cursorColor: cyan,
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: "Search by type, status, URL, date...",
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.38),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        // Clear button
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: _clearSearch,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.12),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white70,
                                size: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Search result count ──
                if (_searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 20, 0),
                    child: Text(
                      filteredItems.isEmpty
                          ? "No results for \"$_searchQuery\""
                          : "${filteredItems.length} result${filteredItems.length == 1 ? '' : 's'} for \"$_searchQuery\"",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: filteredItems.isEmpty
                            ? const Color(0xFFFF5B5B).withOpacity(0.85)
                            : cyan.withOpacity(0.75),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // ── List ──
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
          valueColor: AlwaysStoppedAnimation(Color(0xFF2CC7FF)),
        ),
      );
    }

    if (errorMsg.isNotEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 60),
          Icon(Icons.wifi_off_rounded,
              color: Colors.white.withOpacity(0.4), size: 40),
          const SizedBox(height: 12),
          Text(
            errorMsg,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              onTap: _loadHistory,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 11),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF2CC7FF), Color(0xFF0E7FBF)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text("Retry",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      );
    }

    // No data at all
    if (items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.history_rounded,
              color: Colors.white.withOpacity(0.25), size: 48),
          const SizedBox(height: 12),
          Center(
            child: Text("No scans yet",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              "Scan a link, image or video\nto see results here",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.40), fontSize: 13),
            ),
          ),
        ],
      );
    }

    // Search returned nothing
    if (_searchQuery.isNotEmpty && filteredItems.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.search_off_rounded,
              color: Colors.white.withOpacity(0.25), size: 48),
          const SizedBox(height: 12),
          Center(
            child: Text(
              "No results found",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontWeight: FontWeight.w600,
                  fontSize: 15),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              "Try searching by URL, type (image/video/url),\nstatus (safe/suspicious) or date",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.40), fontSize: 13),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: GestureDetector(
              onTap: _clearSearch,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF2CC7FF).withOpacity(0.25)),
                ),
                child: const Text("Clear Search",
                    style: TextStyle(
                        color: Color(0xFF2CC7FF),
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
            ),
          ),
        ],
      );
    }

    final displayList =
    _searchQuery.isEmpty ? items : filteredItems;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
      itemCount: displayList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) => _buildCard(displayList[i], cyan),
    );
  }

  Widget _buildCard(Map<String, dynamic> it, Color cyan) {
    final score = _historyScore(it);
    final highRisk = score < 40;
    final iconBg =
    highRisk ? const Color(0xFF1B2F47) : const Color(0xFF102E45);
    final iconColor = score >= 70
        ? const Color(0xFF3DDC84)
        : score >= 40
        ? const Color(0xFFFFC107)
        : const Color(0xFFFF5B5B);
    final tagText = _statusText(it);
    final tagBg = _statusBg(it);
    final tagTextColor = _statusColor(it);
    final createdAt = (it["created_at"] ?? it["createdAt"] ??
        it["date"] ?? it["time"] ?? "").toString();

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
      searchQuery: _searchQuery,
    );
  }
}

// ── History Card ─────────────────────────────────────────────────
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
    required this.searchQuery,
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
  final String searchQuery;

  // Highlight matched text
  Widget _highlighted(String text, String query,
      {TextStyle? baseStyle, int? maxLines}) {
    if (query.isEmpty) {
      return Text(text,
          maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null,
          style: baseStyle);
    }

    final lower = text.toLowerCase();
    final lowerQ = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lower.indexOf(lowerQ, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }
      if (idx > start) {
        spans.add(
            TextSpan(text: text.substring(start, idx), style: baseStyle));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: (baseStyle ?? const TextStyle()).copyWith(
          color: const Color(0xFF37C8FF),
          fontWeight: FontWeight.w900,
          backgroundColor: const Color(0xFF37C8FF).withOpacity(0.15),
        ),
      ));
      start = idx + query.length;
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF0A2235).withOpacity(0.55),
        border: Border.all(
            color: borderColor.withOpacity(0.7), width: 1.2),
        boxShadow: [
          BoxShadow(
              color: borderColor.withOpacity(0.08),
              blurRadius: 18,
              spreadRadius: 0.5),
          BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 10)),
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
                    spreadRadius: 1),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _highlighted(
                        title, searchQuery,
                        baseStyle: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: tagTextColor.withOpacity(0.18)),
                      ),
                      child: _highlighted(
                        tagText, searchQuery,
                        baseStyle: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: tagTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                _highlighted(
                  subtitle, searchQuery,
                  maxLines: 1,
                  baseStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(
                      child: _highlighted(
                        time, searchQuery,
                        maxLines: 1,
                        baseStyle: TextStyle(
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