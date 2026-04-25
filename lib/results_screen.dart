import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:social_saver/Bottom%20Navigation%20Bar/video_bg2.dart';
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

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  int trustScore = 0;
  bool isSafe = true;
  Map<String, dynamic> apiData = {};

  int authenticityScore = 0;
  bool isHumanContent = true;
  Map<String, dynamic> mediaData = {};

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeCtrl,
        curve: Curves.easeOut,
      ),
    );

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
      session.loadSession();

      if (_isMediaMode) {
        final result = await TrustScanService.detectMedia(
          userId: session.userId.value,
          file: widget.mediaFile!,
        );

        print("MEDIA RESULT PARSED: $result");

        final detection =
            (result["detection"] as Map<String, dynamic>?) ?? {};

        final bool isAi = detection["is_ai_generated"] == true;
        final bool isDeepfake = detection["is_deepfake"] == true;

        final int computedAuthenticity =
        result["authenticity_score"] is int
            ? result["authenticity_score"] as int
            : _computeAuthenticityFromDetection(detection);

        setState(() {
          mediaData = result;
          authenticityScore = computedAuthenticity.clamp(0, 100);
          isHumanContent =
              result["is_human_content"] == true || (!isAi && !isDeepfake);
          _loading = false;
        });
      } else {
        final result = await TrustScanService.checkUrl(
          userId: session.userId.value,
          url: widget.inputText!.trim(),
        );

        setState(() {
          apiData = result;
          trustScore = TrustScanService.computeTrustScore(result);
          isSafe = !(result["is_threat"] == true);
          _loading = false;
        });
      }

      _fadeCtrl.forward(from: 0);
    } catch (e) {
      print("RESULT SCREEN ERROR: $e");

      setState(() {
        _error = _isMediaMode
            ? "Failed to analyze this media. Please try again."
            : "Failed to scan this URL. Please try again.";
        _loading = false;
      });

      _fadeCtrl.forward(from: 0);
    }
  }

  int _computeAuthenticityFromDetection(Map<String, dynamic> detection) {
    final confStr = (detection["ai_confidence"] ?? "0")
        .toString()
        .replaceAll("%", "")
        .trim();

    final aiConf = double.tryParse(confStr) ?? 0.0;
    return (100 - aiConf).round().clamp(0, 100);
  }

  Color _scoreColor(int score) {
    if (score >= 70) return const Color(0xFF3DDC84);
    if (score >= 40) return const Color(0xFFFFC107);
    return const Color(0xFFFF5B5B);
  }

  IconData _scoreIcon(
      int score, {
        bool isMedia = false,
        bool humanContent = true,
      }) {
    if (isMedia) {
      return humanContent
          ? Icons.verified_user_rounded
          : Icons.smart_display_rounded;
    }

    if (score >= 70) return Icons.verified_user_rounded;
    if (score >= 40) return Icons.report_problem_rounded;
    return Icons.error_rounded;
  }

  String _scoreLabel(
      int score, {
        bool isMedia = false,
        bool humanContent = true,
      }) {
    if (isMedia) {
      if (humanContent && score >= 50) return "Authentic";
      return "AI / Suspicious";
    }

    if (score >= 70) return "Safe";
    if (score >= 40) return "Suspicious";
    return "High Risk";
  }

  String _scoreDescription(
      int score, {
        bool isMedia = false,
        bool humanContent = true,
      }) {
    if (isMedia) {
      return humanContent && score >= 50
          ? "The uploaded media appears authentic and likely human-made."
          : "This media may be AI-generated or manipulated.";
    }

    if (score >= 70) return "The link you shared appeared to be safe!";
    if (score >= 40) return "This link looks suspicious. Proceed with caution!";
    return "This looks very dangerous. Do not open this link!";
  }

  Color _badgeBgColor(int score) {
    if (score >= 70) return const Color(0xFF3DDC84).withOpacity(0.12);
    if (score >= 40) return const Color(0xFFFFC107).withOpacity(0.12);
    return const Color(0xFFFF5B5B).withOpacity(0.12);
  }

  String _safeString(dynamic value, {String fallback = "Unknown"}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _riskLevel() => _safeString(apiData["risk_level"]);

  String _threatTypes() {
    final list = apiData["threat_types"];
    if (list is List && list.isNotEmpty) return list.join(", ");
    return "No threats";
  }

  String _domainAge() => _safeString(apiData["domain_age"]);
  String _registrar() => _safeString(apiData["registrar"]);
  String _createdDate() => _safeString(apiData["created_date"]);

  Map<String, dynamic> get _det =>
      (mediaData["detection"] as Map<String, dynamic>?) ?? {};

  String _mediaVerdict() =>
      _safeString(_det["verdict"] ?? mediaData["verdict"]);

  String _mediaAiConfidence() =>
      _safeString(_det["ai_confidence"] ?? mediaData["ai_confidence"],
          fallback: "0%");

  String _mediaGenerator() =>
      _safeString(_det["generated_by"] ?? mediaData["generated_by"]);

  String _mediaDeepfake() {
    final isDeepfake = _det["is_deepfake"] == true;
    return isDeepfake ? "Detected" : "Not Detected";
  }

  String _mediaFileType() =>
      _safeString(mediaData["file_type"] ?? _det["file_type"]);

  String _mediaFileName() {
    if (widget.mediaFile != null) {
      return widget.mediaFile!.path.split('/').last;
    }

    return _safeString(
      mediaData["file_name"] ?? _det["file_name"],
      fallback: "Selected Media",
    );
  }

  @override
  Widget build(BuildContext context) {
    final String displayInput =
    _isMediaMode ? _mediaFileName() : (widget.inputText ?? "");

    final int activeScore = _isMediaMode ? authenticityScore : trustScore;
    final Color scoreColor = _scoreColor(activeScore);

    return WillPopScope(
      onWillPop: () async {
        Get.back(result: true);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            VideoBackground2(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(result: true),
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
                              child: const LinearProgressIndicator(
                                minHeight: 10,
                                backgroundColor: Colors.white12,
                                valueColor: AlwaysStoppedAnimation(cyan),
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
                          border:
                          Border.all(color: Colors.white.withOpacity(0.08)),
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

                    if (_error != null && !_loading)
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A2235).withOpacity(.55),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFFF6B6B),
                                width: 1,
                              ),
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
                                      borderRadius: BorderRadius.circular(12),
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

                    if (!_loading && _error == null)
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding:
                                const EdgeInsets.fromLTRB(18, 20, 18, 18),
                                decoration: BoxDecoration(
                                  color:
                                  const Color(0xFF0A2235).withOpacity(.60),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: scoreColor.withOpacity(0.45),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: scoreColor.withOpacity(0.08),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _CircularScoreRing(
                                      score: activeScore,
                                      color: scoreColor,
                                      icon: _scoreIcon(
                                        activeScore,
                                        isMedia: _isMediaMode,
                                        humanContent: isHumanContent,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _badgeBgColor(activeScore),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: scoreColor.withOpacity(0.35),
                                        ),
                                      ),
                                      child: Text(
                                        _scoreLabel(
                                          activeScore,
                                          isMedia: _isMediaMode,
                                          humanContent: isHumanContent,
                                        ),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: scoreColor,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _scoreDescription(
                                        activeScore,
                                        isMedia: _isMediaMode,
                                        humanContent: isHumanContent,
                                      ),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12.8,
                                        height: 1.4,
                                        color: Colors.white.withOpacity(.68),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Text(
                                          _isMediaMode
                                              ? "Authenticity Score"
                                              : "Trust Score",
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color:
                                            Colors.white.withOpacity(.60),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const Spacer(),
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
                                    _AnimatedScoreBar(
                                      value: activeScore / 100,
                                      color: scoreColor,
                                    ),
                                    const SizedBox(height: 14),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 9,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.04),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.white10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _isMediaMode
                                                ? Icons.image_outlined
                                                : Icons.link_rounded,
                                            color: cyan.withOpacity(0.7),
                                            size: 14,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              displayInput,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color:
                                                Colors.white.withOpacity(0.55),
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
                                  physics: const NeverScrollableScrollPhysics(),
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
                                      showCheck: apiData["is_threat"] == false,
                                      showAlert: apiData["is_threat"] == true,
                                    ),
                                    _SignalCard(
                                      icon: Icons.report_problem_rounded,
                                      title: "Threats",
                                      value: _threatTypes(),
                                      iconColor: const Color(0xFF8B5CF6),
                                      showCheck: (apiData["threat_types"]
                                      is List) &&
                                          (apiData["threat_types"] as List)
                                              .isEmpty,
                                      showAlert: (apiData["threat_types"]
                                      is List) &&
                                          (apiData["threat_types"] as List)
                                              .isNotEmpty,
                                    ),
                                    _SignalCard(
                                      icon: Icons.access_time_rounded,
                                      title: "Domain Age",
                                      value: _domainAge(),
                                      iconColor: cyan,
                                      showCheck: _domainAge() != "Unknown",
                                    ),
                                    _SignalCard(
                                      icon: Icons.business_rounded,
                                      title: "Registrar",
                                      value: _registrar(),
                                      iconColor: cyan,
                                      showCheck: _registrar() != "Unknown",
                                    ),
                                  ],
                                ),

                              if (_isMediaMode)
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 1.35,
                                  children: [
                                    _SignalCard(
                                      icon: Icons.perm_media_rounded,
                                      title: "File Type",
                                      value: _mediaFileType(),
                                      iconColor: cyan,
                                      showCheck: true,
                                    ),
                                    _SignalCard(
                                      icon: Icons.fact_check_rounded,
                                      title: "Verdict",
                                      value: _mediaVerdict(),
                                      iconColor: const Color(0xFF8B5CF6),
                                      showCheck:
                                      _mediaVerdict().toLowerCase() ==
                                          "human",
                                      showAlert:
                                      _mediaVerdict().toLowerCase() !=
                                          "human",
                                    ),
                                    _SignalCard(
                                      icon: Icons.analytics_rounded,
                                      title: "AI Confidence",
                                      value: _mediaAiConfidence(),
                                      iconColor: cyan,
                                      showCheck:
                                      _mediaVerdict().toLowerCase() ==
                                          "human",
                                      showAlert:
                                      _mediaVerdict().toLowerCase() !=
                                          "human",
                                    ),
                                    _SignalCard(
                                      icon:
                                      Icons.face_retouching_natural_rounded,
                                      title: "Deepfake",
                                      value: _mediaDeepfake(),
                                      iconColor: cyan,
                                      showCheck:
                                      _mediaDeepfake() == "Not Detected",
                                      showAlert: _mediaDeepfake() == "Detected",
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 22),

                              if (!_isMediaMode && _createdDate() != "Unknown")
                                _InfoRow(
                                  icon: Icons.calendar_today_rounded,
                                  label: "Created Date",
                                  value: _createdDate(),
                                ),

                              if (_isMediaMode)
                                _InfoRow(
                                  icon: Icons.auto_awesome_rounded,
                                  label: "Likely Generator",
                                  value: _mediaGenerator(),
                                ),

                              const SizedBox(height: 22),

                              SizedBox(
                                width: double.infinity,
                                height: 70,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => Get.back(result: true),
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.report_gmailerrorred_rounded,
                                        color: Color(0xFFFF6B6B),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isMediaMode
                                            ? "Report this Media"
                                            : "Report this Link",
                                        style: const TextStyle(
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
      ),
    );
  }
}

class _CircularScoreRing extends StatefulWidget {
  const _CircularScoreRing({
    required this.score,
    required this.color,
    required this.icon,
  });

  final int score;
  final Color color;
  final IconData icon;

  @override
  State<_CircularScoreRing> createState() => _CircularScoreRingState();
}

class _CircularScoreRingState extends State<_CircularScoreRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _anim = Tween<double>(
      begin: 0,
      end: widget.score / 100,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeOut,
      ),
    );

    Future.delayed(const Duration(milliseconds: 250), () {
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
      builder: (context, _) {
        final visibleScore = (_anim.value * widget.score).round();

        return SizedBox(
          width: 110,
          height: 110,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.18),
                      blurRadius: 22,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: _anim.value,
                  strokeWidth: 7,
                  backgroundColor: widget.color.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation(widget.color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: widget.color, size: 22),
                  const SizedBox(height: 2),
                  Text(
                    "$visibleScore",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: widget.color,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    "/ 100",
                    style: TextStyle(
                      fontSize: 10,
                      color: widget.color.withOpacity(0.60),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedScoreBar extends StatefulWidget {
  const _AnimatedScoreBar({
    required this.value,
    required this.color,
  });

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

    _anim = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeOut,
      ),
    );

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
          minHeight: 8,
          backgroundColor: Colors.white.withOpacity(.10),
          valueColor: AlwaysStoppedAnimation(widget.color),
        ),
      ),
    );
  }
}

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
                  color: Colors.white.withOpacity(.60),
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
              top: 0,
              right: 0,
              child: Icon(
                Icons.verified_rounded,
                color: Color(0xFF3DDC84),
                size: 18,
              ),
            ),
          if (showAlert)
            const Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.warning_rounded,
                color: Color(0xFFFF5B5B),
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  static const cyan = Color(0xFF2CC7FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: cyan, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.white.withOpacity(0.45),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.88),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}