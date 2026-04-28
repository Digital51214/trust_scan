import 'dart:io';
import 'dart:math' as dartMath;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:social_saver/Bottom%20Navigation%20Bar/video_background.dart';
import 'package:social_saver/Services/loading_animate.dart';
import 'package:social_saver/Services/notify_screen.dart';
import 'package:social_saver/results_screen.dart';
import 'package:social_saver/session/session_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final inputCtrl = TextEditingController();
  final session = SessionController.instance;
  final ImagePicker _picker = ImagePicker();

  late final AnimationController _btnCtrl;
  late final Animation<double> _btnScale;
  late final AnimationController _orbitCtrl;

  bool _isScanning = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    inputCtrl.addListener(() => setState(() {}));

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.15,
    );
    _btnScale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut),
    );
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    inputCtrl.dispose();
    _btnCtrl.dispose();
    _orbitCtrl.dispose();
    super.dispose();
  }

  Future<void> _goToResult() async {
    final text = inputCtrl.text.trim();
    if (text.isEmpty) return;

    await _btnCtrl.forward();
    await _btnCtrl.reverse();

    Get.to(
          () => LoadingScreen(),
      transition: Transition.noTransition,
    );

    await Future.delayed(const Duration(seconds: 2));
    Get.back();

    Get.to(
          () => ResultScreen(inputText: text),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 350),
    );
  }

  Future<void> _pickMediaBottomSheet() async {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        decoration: BoxDecoration(
          color: const Color(0xFF081B2C),
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border.all(
            color: const Color(0xFF37C8FF).withOpacity(0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF37C8FF).withOpacity(0.08),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 55,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Select Media",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Feed visual content into the AI scanner",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _MediaPickTile(
                      icon: Icons.image_rounded,
                      title: "Image",
                      onTap: () async {
                        Get.back();
                        await _pickImage();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MediaPickTile(
                      icon: Icons.videocam_rounded,
                      title: "Video",
                      onTap: () async {
                        Get.back();
                        await _pickVideo();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _pickImage() async {
    final XFile? picked =
    await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    Get.to(
          () => ResultScreen(mediaFile: File(picked.path)),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 350),
    );
  }

  Future<void> _pickVideo() async {
    final XFile? picked =
    await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;
    Get.to(
          () => ResultScreen(mediaFile: File(picked.path)),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = MediaQuery.of(context);
    final bottomPad = m.padding.bottom;
    final hasText = inputCtrl.text.trim().isNotEmpty;

    return Scaffold(

      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Video Background ──────────────────────────────────
          Positioned.fill(child: VideoBackground()),

          // ── Linear overlay ────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.22),
                    Colors.transparent,
                    const Color(0xFF061B2B).withOpacity(0.22),
                    const Color(0xFF061B2B).withOpacity(0.82),
                  ],
                  stops: const [0.0, 0.28, 0.62, 1.0],
                ),
              ),
            ),
          ),

          // ── Radial overlay ────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.15),
                  radius: 1.05,
                  colors: [
                    const Color(0xFF37C8FF).withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Stack(
                children: [
                  // ── Top section ───────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),

                      // Header row
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF37C8FF)
                                    .withOpacity(0.18),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF37C8FF)
                                      .withOpacity(0.10),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                              image: const DecorationImage(
                                image: AssetImage(
                                    "assets/images/logo.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Welcome back,",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Obx(() {
                                final name =
                                session.name.value.trim();
                                return Text(
                                  name.isEmpty ? "User" : name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                );
                              }),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Get.to(
                                    () => NotificationScreen(),
                                transition: Transition.noTransition,
                                duration: Duration.zero,
                              );
                            },
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: Lottie.asset(
                                  "assets/images/notification_animation.json",
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                  repeat: true,
                                  animate: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // AI badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF37C8FF)
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFF37C8FF)
                                .withOpacity(0.18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF37C8FF)
                                  .withOpacity(0.06),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 13,
                              color: Color(0xFF37C8FF),
                            ),
                            SizedBox(width: 6),
                            Text(
                              "AI Threat Intelligence",
                              style: TextStyle(
                                color: Color(0xFFC7F7FF),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.25,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Scan. Detect. Outsmart AI Scams.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          height: 1.18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.15,
                        ),
                      ),

                      const SizedBox(height: 2),

                      const Text(
                        "Paste a link, suspicious message, or upload media to let your AI safety layer inspect it instantly.",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 12),
                      _buildFeatures(),
                    ],
                  ),

                  // ── Center Lottie ─────────────────────────────
                  Align(
                    alignment: const Alignment(0, 0.10),
                    child: Opacity(
                      opacity: 0.55,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 250,
                          height: 250,
                          child: Lottie.asset(
                            "assets/images/Flow_5.json",
                            fit: BoxFit.contain,
                            repeat: true,
                            animate: true,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Bottom input section ──────────────────────
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding:
                      EdgeInsets.only(bottom: bottomPad + 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedOpacity(
                            opacity: _isScanning ? 1.0 : 0.0,
                            duration:
                            const Duration(milliseconds: 250),
                            child: const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: _PulsingText("Analyzing..."),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Input bar with orbit dots
                          AnimatedBuilder(
                            animation: _orbitCtrl,
                            builder: (context, child) {
                              final angle =
                                  _orbitCtrl.value * 6.28318530718;
                              const orbitRadius = 132.0;

                              return SizedBox(
                                width: double.infinity,
                                height: 68,
                                child: Stack(
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      left: (MediaQuery.of(context)
                                          .size
                                          .width -
                                          36 -
                                          18 -
                                          18) /
                                          2 +
                                          orbitRadius *
                                              (0.88 *
                                                  MathHelper.cos(
                                                      angle)),
                                      top: 34 +
                                          orbitRadius *
                                              (0.18 *
                                                  MathHelper.sin(
                                                      angle)) -
                                          5,
                                      child: _OrbitDot(
                                        opacity:
                                        _isFocused ? 1.0 : 0.72,
                                      ),
                                    ),
                                    Positioned(
                                      left: (MediaQuery.of(context)
                                          .size
                                          .width -
                                          36 -
                                          18 -
                                          18) /
                                          2 +
                                          orbitRadius *
                                              (0.88 *
                                                  MathHelper.cos(
                                                      angle + 2.094)),
                                      top: 34 +
                                          orbitRadius *
                                              (0.18 *
                                                  MathHelper.sin(
                                                      angle + 2.094)) -
                                          4,
                                      child: _OrbitDot(
                                        size: 7,
                                        opacity:
                                        _isFocused ? 0.95 : 0.58,
                                      ),
                                    ),
                                    Positioned(
                                      left: (MediaQuery.of(context)
                                          .size
                                          .width -
                                          36 -
                                          18 -
                                          18) /
                                          2 +
                                          orbitRadius *
                                              (0.88 *
                                                  MathHelper.cos(
                                                      angle + 4.188)),
                                      top: 34 +
                                          orbitRadius *
                                              (0.18 *
                                                  MathHelper.sin(
                                                      angle + 4.188)) -
                                          4,
                                      child: _OrbitDot(
                                        size: 5.5,
                                        opacity:
                                        _isFocused ? 0.85 : 0.42,
                                      ),
                                    ),
                                    child!,
                                  ],
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration:
                              const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14),
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFF081A2A),
                                borderRadius:
                                BorderRadius.circular(28),
                                border: Border.all(
                                  color: const Color(0xFF37C8FF)
                                      .withOpacity(
                                      _isFocused ? 0.90 : 0.62),
                                  width: _isFocused ? 1.4 : 1.1,
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFF0E2235)
                                        .withOpacity(0.98),
                                    const Color(0xFF081A2A)
                                        .withOpacity(0.99),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF37C8FF)
                                        .withOpacity(
                                        _isFocused ? 0.32 : 0.16),
                                    blurRadius: _isFocused ? 24 : 16,
                                    spreadRadius:
                                    _isFocused ? 1.2 : 0.5,
                                    offset: Offset.zero,
                                  ),
                                  BoxShadow(
                                    color:
                                    Colors.black.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.link_rounded,
                                    color: const Color(0xFF37C8FF)
                                        .withOpacity(0.95),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Focus(
                                      onFocusChange: (hasFocus) =>
                                          setState(() =>
                                          _isFocused = hasFocus),
                                      child: TextField(
                                        controller: inputCtrl,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        textInputAction:
                                        TextInputAction.search,
                                        onSubmitted: (_) =>
                                            _goToResult(),
                                        cursorColor:
                                        const Color(0xFF37C8FF),
                                        decoration: InputDecoration(
                                          hintText:
                                          "Paste link, deal, or message for AI scan...",
                                          hintStyle: TextStyle(
                                            color: Colors.white
                                                .withOpacity(0.34),
                                            fontSize: 13,
                                            fontWeight:
                                            FontWeight.w400,
                                          ),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding:
                                          EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Camera icon
                                  GestureDetector(
                                    onTap: _pickMediaBottomSheet,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        color: const Color(0xFF37C8FF)
                                            .withOpacity(0.95),
                                        size: 18,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Scanner icon
                                  GestureDetector(
                                    onTap: _isScanning
                                        ? null
                                        : _goToResult,
                                    child:
                                    _ScannerIcon(hasText: hasText),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),
                          _TrustIndicatorPlaceholder(
                              hasText: hasText),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  SCANNER ICON — Xerox slow scan, reverse animation
// ════════════════════════════════════════════════════════════════


class _ScannerIcon extends StatefulWidget {
  const _ScannerIcon({required this.hasText});
  final bool hasText;

  @override
  State<_ScannerIcon> createState() => _ScannerIconState();
}

class _ScannerIconState extends State<_ScannerIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _lightPos;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // ✅ Manual forward → reverse → forward animation
    _lightPos = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 50,
      ),
    ]).animate(_ctrl);

    if (widget.hasText) {
      _ctrl.repeat();
    }
  }

  @override
  void didUpdateWidget(_ScannerIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.hasText) {
      if (!_ctrl.isAnimating) {
        _ctrl.repeat();
      }
    } else {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF37C8FF);
    const iconSize = 24.0;
    const lightHeight = 1.6;
    const topMin = 5.0;
    const topMax = iconSize - lightHeight - 5.0;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final glowIntensity = _lightPos.value < 0.5
            ? _lightPos.value * 2
            : (1 - _lightPos.value) * 2;

        final lightTop =
            topMin + _lightPos.value * (topMax - topMin);

        return Stack(
          alignment: Alignment.center,
          children: [
            if (widget.hasText)
              Container(
                width: iconSize + 5,
                height: iconSize + 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: cyan.withOpacity(
                        0.20 + 0.25 * glowIntensity,
                      ),
                      blurRadius: 14,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),

            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: iconSize-2,
                height: iconSize-2,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            5,
                                (i) => Container(
                              height: 1.5,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.22),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (widget.hasText)
                      Positioned(
                        left: 3,
                        right: 3,
                        top: lightTop,
                        child: Container(
                          height: lightHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.95),
                                Colors.white.withOpacity(0.95),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.25, 0.75, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(1),
                            boxShadow: [
                              BoxShadow(
                                color: cyan.withOpacity(0.75),
                                blurRadius: 6,
                                spreadRadius: 0.4,
                              ),
                            ],
                          ),
                        ),
                      ),

                    Positioned.fill(
                      child: CustomPaint(
                        painter: _QrCornerPainter(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
// ════════════════════════════════════════════════════════════════
//  QR CORNER PAINTER
// ════════════════════════════════════════════════════════════════

class _QrCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.90)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const gap = 4.0;
    const len = 4.0;

    // Top-left
    canvas.drawLine(
        Offset(gap, gap + len), Offset(gap, gap), paint);
    canvas.drawLine(
        Offset(gap, gap), Offset(gap + len, gap), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - gap - len, gap),
        Offset(size.width - gap, gap), paint);
    canvas.drawLine(Offset(size.width - gap, gap),
        Offset(size.width - gap, gap + len), paint);
    // Bottom-left
    canvas.drawLine(Offset(gap, size.height - gap - len),
        Offset(gap, size.height - gap), paint);
    canvas.drawLine(Offset(gap, size.height - gap),
        Offset(gap + len, size.height - gap), paint);
    // Bottom-right
    canvas.drawLine(
        Offset(size.width - gap - len, size.height - gap),
        Offset(size.width - gap, size.height - gap),
        paint);
    canvas.drawLine(
        Offset(size.width - gap, size.height - gap - len),
        Offset(size.width - gap, size.height - gap),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ════════════════════════════════════════════════════════════════
//  ORBIT DOT
// ════════════════════════════════════════════════════════════════

class _OrbitDot extends StatelessWidget {
  const _OrbitDot({this.size = 8, this.opacity = 0.72});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF37C8FF).withOpacity(opacity),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF37C8FF)
                  .withOpacity(opacity * 0.75),
              blurRadius: 10,
              spreadRadius: 1.2,
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  TRUST INDICATOR
// ════════════════════════════════════════════════════════════════

class _TrustIndicatorPlaceholder extends StatelessWidget {
  const _TrustIndicatorPlaceholder({required this.hasText});
  final bool hasText;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasText
              ? const Color(0xFF37C8FF).withOpacity(0.20)
              : Colors.white.withOpacity(0.07),
        ),
        boxShadow: hasText
            ? [
          BoxShadow(
            color: const Color(0xFF37C8FF).withOpacity(0.06),
            blurRadius: 12,
            spreadRadius: 0.8,
          ),
        ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 14,
            color: hasText
                ? const Color(0xFF37C8FF).withOpacity(0.75)
                : Colors.white30,
          ),
          const SizedBox(width: 7),
          Text(
            hasText
                ? "Tap Scan to generate your AI trust score"
                : "Your AI trust score will appear here",
            style: TextStyle(
              color: hasText
                  ? const Color(0xFF37C8FF).withOpacity(0.78)
                  : Colors.white30,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  PULSING TEXT
// ════════════════════════════════════════════════════════════════

class _PulsingText extends StatefulWidget {
  const _PulsingText(this.text);
  final String text;

  @override
  State<_PulsingText> createState() => _PulsingTextState();
}

class _PulsingTextState extends State<_PulsingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Text(
        widget.text,
        style: const TextStyle(
          color: Color(0xFF37C8FF),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  MEDIA PICK TILE
// ════════════════════════════════════════════════════════════════

class _MediaPickTile extends StatelessWidget {
  const _MediaPickTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF37C8FF).withOpacity(0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF37C8FF).withOpacity(0.05),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF37C8FF), size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  FEATURE CHIPS
// ════════════════════════════════════════════════════════════════

Widget _buildFeatures() {
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: const [
      _FeatureChip(
          icon: Icons.lock_outline_rounded, label: "Private Shield"),
      _FeatureChip(
          icon: Icons.flash_on_rounded, label: "AI Detection"),
      _FeatureChip(
          icon: Icons.verified_outlined, label: "Trust Score"),
      _FeatureChip(icon: Icons.shield_outlined, label: "Scam Guard"),
    ],
  );
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF37C8FF).withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF37C8FF).withOpacity(0.03),
            blurRadius: 8,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF37C8FF)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  MATH HELPER
// ════════════════════════════════════════════════════════════════

class MathHelper {
  static double sin(double x) => dartMath.sin(x);
  static double cos(double x) => dartMath.cos(x);
}