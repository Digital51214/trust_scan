import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:social_saver/session/session_controller.dart';

import 'Services/trust_scan_service.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    this.inputText,
    this.mediaFile,
  });

  final String? inputText;
  final File? mediaFile;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  static const bg = Color(0xFF061B2B);
  static const cyan = Color(0xFF2CC7FF);

  bool _loading = true;
  String? _error;
  bool _isMediaMode = false;

  // Fade-in animation for result card
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // URL mode values
  int trustScore = 0;
  bool isSafe = true;
  Map<String, dynamic> apiData = {};

  // Media mode values
  int authenticityScore = 0;
  bool isHumanContent = true;
  Map<String, dynamic> mediaData = {};

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));

    _isMediaMode = widget.mediaFile != null;
    _hitApi();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _hitApi() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = SessionController.instance;

      if (_isMediaMode) {
        final result = await TrustScanService.detectMedia(
          userId: session.userId.value,
          file: widget.mediaFile!,
        );

        final detection = result["detection"] ?? {};
        final bool isAi = detection["is_ai_generated"] == true;
        final bool isDeepfake = detection["is_deepfake"] == true;

        final String aiConfidenceText =
        (detection["ai_confidence"] ?? "0%").toString().replaceAll("%", "");
        final double aiConfidence =
            double.tryParse(aiConfidenceText.trim()) ?? 0;

        final int computedAuthenticity =
        (100 - aiConfidence).round().clamp(0, 100);

        setState(() {
          mediaData = result;
          authenticityScore = computedAuthenticity;
          isHumanContent = !isAi && !isDeepfake;
          _loading = false;
        });
      } else {
        final result = await TrustScanService.checkUrl(
          userId: session.userId.value,
          url: widget.inputText!.trim(),
        );

        // ✅ Local + API merged score (replaces old switch-case)
        setState(() {
          apiData = result;
          trustScore = TrustScanService.computeTrustScore(result);
          isSafe = !(result["is_threat"] == true);
          _loading = false;
        });
      }

      // Trigger fade-in once data is ready
      _fadeCtrl.forward();
    } catch (e) {
      setState(() {
        _error = _isMediaMode
            ? "Failed to analyze this media. Please try again."
            : "Failed to scan this URL. Please try again.";
        _loading = false;
      });
      _fadeCtrl.forward();
    }
  }

  // ── Color-coded score helpers ───────────────────────────────────────────────
  /// Returns green / yellow / red based on score value
  Color _scoreColor(int score) {
    if (score >= 70) return const Color(0xFF3DDC84); // green
    if (score >= 40) return const Color(0xFFFFC107); // yellow
    return const Color(0xFFFF5B5B);                  // red
  }

  /// Icon based on score category
  IconData _scoreIcon(int score, {bool isMedia = false, bool humanContent = true}) {
    if (isMedia) {
      return humanContent ? Icons.verified_user_rounded : Icons.smart_display_rounded;
    }
    if (score >= 70) return Icons.verified_user_rounded;   // green → safe
    if (score >= 40) return Icons.report_problem_rounded;  // yellow → risky
    return Icons.error_rounded;                            // red → danger
  }

  /// Label text based on score category
  String _scoreLabel(int score, {bool isMedia = false, bool humanContent = true}) {
    if (isMedia) return humanContent ? "Authentic" : "AI / Suspicious";
    if (score >= 70) return "Safe";
    if (score >= 40) return "Suspicious";
    return "High Risk";
  }

  /// Description text based on score category
  String _scoreDescription(int score, {bool isMedia = false, bool humanContent = true}) {
    if (isMedia) {
      return humanContent
          ? "The uploaded media appears authentic and likely human-made."
          : "This media may be AI-generated or manipulated.";
    }
    if (score >= 70) return "The link you shared appeared to be safe!";
    if (score >= 40) return "This link looks suspicious. Proceed with caution!";
    return "This looks very dangerous. Do not open this link!";
  }

  String _safeString(dynamic value, {String fallback = "Unknown"}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _riskLevel() => _safeString(apiData["risk_level"], fallback: "Unknown");

  String _threatTypes() {
    final list = apiData["threat_types"];
    if (list is List && list.isNotEmpty) return list.join(", ");
    return "No threats";
  }

  String _domainAge() => _safeString(apiData["domain_age"]);
  String _registrar() => _safeString(apiData["registrar"]);
  String _createdDate() => _safeString(apiData["created_date"]);

  String _mediaVerdict() =>
      _safeString(mediaData["detection"]?["verdict"], fallback: "Unknown");

  String _mediaAiConfidence() =>
      _safeString(mediaData["detection"]?["ai_confidence"], fallback: "0%");

  String _mediaGenerator() =>
      _safeString(mediaData["detection"]?["generated_by"], fallback: "Unknown");

  String _mediaDeepfake() {
    final isDeepfake = mediaData["detection"]?["is_deepfake"] == true;
    return isDeepfake ? "Detected" : "Not Detected";
  }

  String _mediaFileType() =>
      _safeString(mediaData["file_type"], fallback: "Unknown");

  String _mediaFileName() {
    if (widget.mediaFile != null) {
      return widget.mediaFile!.path.split('/').last;
    }
    return _safeString(mediaData["file_name"], fallback: "Selected Media");
  }

  @override
  Widget build(BuildContext context) {
    final String displayInput =
    _isMediaMode ? _mediaFileName() : (widget.inputText ?? "");

    final int activeScore = _isMediaMode ? authenticityScore : trustScore;
    final Color scoreColor = _scoreColor(activeScore);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D5E7D),
                  bg,
                  Color(0xFF040F1D),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── App bar ───────────────────────────────────────────────
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Image.asset(
                          "assets/images/back_icon.png",
                          height: 44,
                          width: 44,
                        ),
                      ),
                      const Spacer(),
                      Image.asset(
                        "assets/images/logo.png",
                        width: 85,
                        height: 85,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Loading state ─────────────────────────────────────────
                  if (_loading) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A2235).withOpacity(.55),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cyan, width: 1),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: Lottie.asset(
                              "assets/images/Flow_5.json",
                              repeat: true,
                              animate: true,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _isMediaMode
                                ? "Analyzing media…"
                                : "Checking the URL…",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isMediaMode
                                ? "Please wait while we inspect the image/video for AI, deepfake, and authenticity signals."
                                : "Please wait while we analyze the link for scams & threats.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.8,
                              height: 1.35,
                              color: Colors.white.withOpacity(.72),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 10,
                              backgroundColor: Colors.white.withOpacity(.12),
                              valueColor:
                              const AlwaysStoppedAnimation(cyan),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Text(
                        displayInput,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  // ── Error state ───────────────────────────────────────────
                  if (_error != null && !_loading)
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                          decoration: BoxDecoration(
                            color:
                            const Color(0xFF0A2235).withOpacity(.55),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFFFF6B6B), width: 1),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: Color(0xFFFF6B6B),
                                size: 34,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.85),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: _hitApi,
                                child: Container(
                                  height: 46,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF37C8FF),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "Retry",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // ── Result state (fade + slide in) ────────────────────────
                  if (!_loading && _error == null)
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Score card
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                  18, 16, 18, 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A2235)
                                    .withOpacity(.55),
                                borderRadius: BorderRadius.circular(14),
                                border:
                                Border.all(color: cyan, width: 1),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                      scoreColor.withOpacity(.15),
                                      border: Border.all(
                                          color: scoreColor
                                              .withOpacity(.55)),
                                    ),
                                    child: Icon(
                                      _scoreIcon(activeScore,
                                          isMedia: _isMediaMode,
                                          humanContent: isHumanContent),
                                      color: scoreColor,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _scoreLabel(activeScore,
                                        isMedia: _isMediaMode,
                                        humanContent: isHumanContent),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: scoreColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _scoreDescription(activeScore,
                                        isMedia: _isMediaMode,
                                        humanContent: isHumanContent),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12.8,
                                      height: 1.35,
                                      color:
                                      Colors.white.withOpacity(.72),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Text(
                                        _isMediaMode
                                            ? "Authenticity Score"
                                            : "Trust Score",
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.white
                                              .withOpacity(.65),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Color-coded percentage label
                                      Text(
                                        "$activeScore%",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: scoreColor,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Color-coded animated progress bar
                                  _AnimatedScoreBar(
                                    value: activeScore / 100,
                                    color: scoreColor,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 22),

                            const Text(
                              "Key Signals",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 14),

                            if (!_isMediaMode)
                              GridView.count(
                                shrinkWrap: true,
                                physics:
                                const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1.35,
                                children: [
                                  _SignalCard(
                                    icon: Icons.shield_rounded,
                                    title: "Risk Level",
                                    value: _riskLevel(),
                                    iconColor: cyan,
                                    showCheck:
                                    apiData["is_threat"] == false,
                                    showAlert:
                                    apiData["is_threat"] == true,
                                  ),
                                  _SignalCard(
                                    icon:
                                    Icons.report_problem_rounded,
                                    title: "Threats",
                                    value: _threatTypes(),
                                    iconColor:
                                    const Color(0xFF8B5CF6),
                                    showCheck: (apiData[
                                    "threat_types"]
                                    is List) &&
                                        (apiData["threat_types"]
                                        as List)
                                            .isEmpty,
                                    showAlert: (apiData[
                                    "threat_types"]
                                    is List) &&
                                        (apiData["threat_types"]
                                        as List)
                                            .isNotEmpty,
                                  ),
                                  _SignalCard(
                                    icon:
                                    Icons.access_time_rounded,
                                    title: "Domain Age",
                                    value: _domainAge(),
                                    iconColor: cyan,
                                    showCheck:
                                    _domainAge() != "Unknown",
                                  ),
                                  _SignalCard(
                                    icon: Icons.business_rounded,
                                    title: "Registrar",
                                    value: _registrar(),
                                    iconColor: cyan,
                                    showCheck:
                                    _registrar() != "Unknown",
                                  ),
                                ],
                              ),

                            if (_isMediaMode)
                              GridView.count(
                                shrinkWrap: true,
                                physics:
                                const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1.35,
                                children: [
                                  _SignalCard(
                                    icon:
                                    Icons.perm_media_rounded,
                                    title: "File Type",
                                    value: _mediaFileType(),
                                    iconColor: cyan,
                                    showCheck: true,
                                  ),
                                  _SignalCard(
                                    icon:
                                    Icons.fact_check_rounded,
                                    title: "Verdict",
                                    value: _mediaVerdict(),
                                    iconColor:
                                    const Color(0xFF8B5CF6),
                                    showCheck: _mediaVerdict()
                                        .toLowerCase() ==
                                        "human",
                                    showAlert: _mediaVerdict()
                                        .toLowerCase() !=
                                        "human",
                                  ),
                                  _SignalCard(
                                    icon:
                                    Icons.analytics_rounded,
                                    title: "AI Confidence",
                                    value: _mediaAiConfidence(),
                                    iconColor: cyan,
                                    showCheck: _mediaVerdict()
                                        .toLowerCase() ==
                                        "human",
                                    showAlert: _mediaVerdict()
                                        .toLowerCase() !=
                                        "human",
                                  ),
                                  _SignalCard(
                                    icon: Icons
                                        .face_retouching_natural_rounded,
                                    title: "Deepfake",
                                    value: _mediaDeepfake(),
                                    iconColor: cyan,
                                    showCheck: _mediaDeepfake() ==
                                        "Not Detected",
                                    showAlert:
                                    _mediaDeepfake() == "Detected",
                                  ),
                                ],
                              ),

                            const SizedBox(height: 22),

                            if (!_isMediaMode &&
                                _createdDate() != "Unknown")
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                    14, 14, 14, 14),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(0.05),
                                  borderRadius:
                                  BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Colors.white10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                      color: cyan,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Created Date: ${_createdDate()}",
                                        style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(.88),
                                          fontWeight:
                                          FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (_isMediaMode)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                    14, 14, 14, 14),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(0.05),
                                  borderRadius:
                                  BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Colors.white10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome_rounded,
                                      color: cyan,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Likely Generator: ${_mediaGenerator()}",
                                        style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(.88),
                                          fontWeight:
                                          FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 22),

                            SizedBox(
                              width: double.infinity,
                              height: 70,
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(999),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => Get.back(),
                                    child: Center(
                                      child: Lottie.asset(
                                        "assets/images/Check_Link.json",
                                        fit: BoxFit.contain,
                                        repeat: true,
                                        animate: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            Center(
                              child: GestureDetector(
                                onTap: () {},
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons
                                          .report_gmailerrorred_rounded,
                                      color: Color(0xFFFF6B6B),
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Report this Link",
                                      style: TextStyle(
                                        color: Color(0xFFFF6B6B),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated color-coded score bar ───────────────────────────────────────────
class _AnimatedScoreBar extends StatefulWidget {
  const _AnimatedScoreBar({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  State<_AnimatedScoreBar> createState() => _AnimatedScoreBarState();
}

class _AnimatedScoreBarState extends State<_AnimatedScoreBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    // Small delay so it starts after the fade-in
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: _anim.value,
          minHeight: 10,
          backgroundColor: Colors.white.withOpacity(.12),
          valueColor: AlwaysStoppedAnimation(widget.color),
        ),
      ),
    );
  }
}

// ── Signal card ───────────────────────────────────────────────────────────────
class _SignalCard extends StatelessWidget {
  const _SignalCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
    this.showCheck = false,
    this.showAlert = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;
  final bool showCheck;
  final bool showAlert;

  static const cyan = Color(0xFF2CC7FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2235).withOpacity(.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(.65),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.2,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (showCheck)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.verified_rounded,
                  color: Color(0xFF3DDC84), size: 18),
            ),
          if (showAlert)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.warning_rounded,
                  color: Color(0xFFFF5B5B), size: 18),
            ),
        ],
      ),
    );
  }
}