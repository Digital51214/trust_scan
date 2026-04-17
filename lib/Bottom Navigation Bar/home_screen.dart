import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import 'package:social_saver/results_screen.dart';
import 'package:social_saver/session/session_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final inputCtrl = TextEditingController();
  final session = SessionController.instance;
  final ImagePicker _picker = ImagePicker();

  late final AnimationController _btnCtrl;
  late final Animation<double> _btnScale;

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
  }

  @override
  void dispose() {
    inputCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  Future<void> _goToResult() async {
    final text = inputCtrl.text.trim();
    if (text.isEmpty) return;

    await _btnCtrl.forward();
    await _btnCtrl.reverse();

    setState(() => _isScanning = true);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _isScanning = false);

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
        decoration: const BoxDecoration(
          color: Color(0xFF0A2235),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
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
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    Get.to(
          () => ResultScreen(mediaFile: File(picked.path)),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 350),
    );
  }

  Future<void> _pickVideo() async {
    final XFile? picked = await _picker.pickVideo(source: ImageSource.gallery);
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
          // Background
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg.png",
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Stack(
                children: [
                  // ── Top content ──────────────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white12, width: 2),
                              image: const DecorationImage(
                                image: AssetImage("assets/images/logo.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Welcome!",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Obx(() {
                                final name = session.name.value.trim();
                                return Text(
                                  name.isEmpty ? "User" : name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                );
                              }),
                            ],
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 38,
                            height: 38,
                            child: Center(
                              child: Lottie.asset(
                                "assets/images/notification_animation.json",
                                width: 44,
                                height: 44,
                                fit: BoxFit.contain,
                                repeat: true,
                                animate: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Scan,Detect & Stay Safe",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        "Paste a link or upload a screenshot to get a trust score",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      _buildFeatures(),
                    ],
                  ),

                  // ── Center Lottie swirl ──────────────────────────────
                  Align(
                    alignment: const Alignment(0.0, 0.15),
                    child: Opacity(
                      opacity: 0.55,
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: Lottie.asset(
                          "assets/images/Flow_5.json",
                          fit: BoxFit.contain,
                          repeat: true,
                          animate: true,
                        ),
                      ),
                    ),
                  ),

                  // ── Bottom input bar ─────────────────────────────────
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomPad + 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedOpacity(
                            opacity: _isScanning ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 250),
                            child: const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: _PulsingText("Analyzing..."),
                            ),
                          ),

                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF061220),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _isFocused
                                    ? const Color(0xFF37C8FF).withOpacity(0.7)
                                    : const Color(0xFF37C8FF).withOpacity(0.18),
                                width: _isFocused ? 1.5 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF37C8FF)
                                      .withOpacity(_isFocused ? 0.22 : 0.08),
                                  blurRadius: _isFocused ? 28 : 14,
                                  spreadRadius: _isFocused ? 2 : 0,
                                  offset: Offset.zero,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Focus(
                                    onFocusChange: (hasFocus) =>
                                        setState(() => _isFocused = hasFocus),
                                    child: TextField(
                                      controller: inputCtrl,
                                      style: const TextStyle(color: Colors.white),
                                      textInputAction: TextInputAction.search,
                                      onSubmitted: (_) => _goToResult(),
                                      decoration: InputDecoration(
                                        hintText: "Paste link or message...",
                                        hintStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.35),
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),

                                GestureDetector(
                                  onTap: _pickMediaBottomSheet,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(.08),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                _ScanButton(
                                  isScanning: _isScanning,
                                  scaleAnim: _btnScale,
                                  onTap: _isScanning ? null : _goToResult,
                                  hasText: hasText,
                                ),
                              ],
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
        ],
      ),
    );
  }
}


// ── Beautiful Glowing Scan Button ────────────────────────────────────────────
class _ScanButton extends StatefulWidget {
  const _ScanButton({
    required this.isScanning,
    required this.scaleAnim,
    required this.onTap,
    required this.hasText,
  });

  final bool isScanning;
  final Animation<double> scaleAnim;
  final VoidCallback? onTap;
  final bool hasText;

  @override
  State<_ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<_ScanButton>
    with TickerProviderStateMixin {
  late final AnimationController _ringCtrl;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

  late final AnimationController _rotCtrl;
  late final Animation<double> _rotAnim;

  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _ringScale = Tween<double>(begin: 1.0, end: 1.45).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
    );
    _ringOpacity = Tween<double>(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
    );

    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _rotAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotCtrl, curve: Curves.linear),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _glowAnim = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_ScanButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.hasText && !oldWidget.hasText) {
      // Text aaya — animations shuru karo
      _ringCtrl.repeat();
      _rotCtrl.repeat();
      _glowCtrl.repeat(reverse: true);
    } else if (!widget.hasText && oldWidget.hasText) {
      // Text gaya — animations band karo
      _ringCtrl.stop();
      _rotCtrl.stop();
      _glowCtrl.stop();
    }
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _rotCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          widget.scaleAnim,
          _ringScale,
          _ringOpacity,
          _rotAnim,
          _glowAnim,
        ]),
        builder: (context, _) {
          return Transform.scale(
            scale: widget.scaleAnim.value,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!widget.isScanning && widget.hasText)
                    Transform.scale(
                      scale: _ringScale.value,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF37C8FF)
                                .withOpacity(_ringOpacity.value),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.isScanning
                            ? [
                          const Color(0xFF37C8FF).withOpacity(0.6),
                          const Color(0xFF1A8FD1).withOpacity(0.6),
                        ]
                            : const [
                          Color(0xFF37C8FF),
                          Color(0xFF0E7FBF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF37C8FF).withOpacity(
                            widget.isScanning
                                ? 0.15
                                : widget.hasText
                                ? _glowAnim.value * 0.7
                                : 0.1,
                          ),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: widget.isScanning
                        ? const Padding(
                      padding: EdgeInsets.all(11),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                        : Stack(
                      alignment: Alignment.center,
                      children: [
                        if (widget.hasText)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(
                                      -1.5 + _glowAnim.value * 3, -1),
                                  end: Alignment(
                                      0.5 + _glowAnim.value * 3, 1),
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.22),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        widget.hasText
                            ? RotationTransition(
                          turns: _rotAnim,
                          child: const Icon(
                            Icons.radar_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        )
                            : const Icon(
                          Icons.radar_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


// ── Pulsing "Analyzing..." text ──────────────────────────────────────────────
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


// ── Media pick tile ──────────────────────────────────────────────────────────
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
          border: Border.all(color: Colors.white10),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildFeatures() {
  return Padding(
    padding: const EdgeInsets.only(left: 12, top: 5),
    child: Column(
      children: [
        Row(
          children: [
            const Icon(Icons.circle, size: 10, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              "Secure & Private Scanning",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 17),
            )
          ],
        ),
        Row(
          children: [
            const Icon(Icons.circle, size: 10, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              "Powered by AI Detection",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 17),
            )
          ],
        ),
        Row(
          children: [
            const Icon(Icons.circle, size: 10, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              "Trust Score Preview Badge",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 17),
            )
          ],
        ),
        Row(
          children: [
            const Icon(Icons.circle, size: 10, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              "Builds Credibility Instantly",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 17),
            )
          ],
        ),
      ],
    ),
  );
}