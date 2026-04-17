import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:social_saver/Authentication%20Screens/change_password_screen.dart';
import 'package:social_saver/services/forgot_password_service.dart';

class EnterCodeScreen extends StatefulWidget {
  final String email;
  final int userId;
  final String serverOtp;

  const EnterCodeScreen({
    super.key,
    required this.email,
    required this.userId,
    required this.serverOtp,
  });

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  static const cyan = Color(0xFF2CC7FF);

  final List<TextEditingController> ctrls =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> nodes = List.generate(6, (_) => FocusNode());

  bool isLoading = false;

  late String _otpFromApi;
  late int _userId;

  @override
  void initState() {
    super.initState();
    _otpFromApi = widget.serverOtp;
    _userId = widget.userId;
  }

  @override
  void dispose() {
    for (final c in ctrls) c.dispose();
    for (final n in nodes) n.dispose();
    super.dispose();
  }

  String get code => ctrls.map((e) => e.text).join();

  void _msg(String msg) {
    if (msg.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _onChanged(int i, String v) {
    if (v.length > 1) {
      final chars = v.characters.toList();
      for (int k = 0; k < 6; k++) {
        ctrls[k].text = k < chars.length ? chars[k] : "";
      }
      FocusScope.of(context).unfocus();
      return;
    }
    if (v.isNotEmpty && i < 5) {
      FocusScope.of(context).requestFocus(nodes[i + 1]);
    }
  }

  void _onBackspace(int i) {
    if (ctrls[i].text.isEmpty && i > 0) {
      FocusScope.of(context).requestFocus(nodes[i - 1]);
      ctrls[i - 1].clear();
    }
  }

  Future<void> _resendOtp() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    print("🟦 RESEND OTP PRESSED");
    print("📧 EMAIL: ${widget.email}");

    final result = await ForgotPasswordService.resendOtp(widget.email);

    print("✅ RESEND OTP RESULT MAP: $result");

    setState(() => isLoading = false);

    final success = result["success"] == true;
    final message = (result["message"] ?? "").toString();

    if (success) {
      final data = result["data"];
      final newOtp = (data?["otp"] ?? "").toString();
      final newUserId = data?["user_id"];

      if (newOtp.isNotEmpty) _otpFromApi = newOtp;
      if (newUserId != null) {
        _userId = int.tryParse(newUserId.toString()) ?? _userId;
      }

      print("🔢 UPDATED OTP: $_otpFromApi");
      print("🆔 UPDATED USER ID: $_userId");

      if (message.isNotEmpty) _msg(message);
    } else {
      if (message.isNotEmpty) _msg(message);
    }
  }

  void _verifyAndGoNext() {
    final entered = code.trim();

    if (entered.length != 6) {
      _msg("Please enter complete OTP");
      return;
    }

    print("🟦 VERIFY OTP PRESSED");
    print("⌨️ ENTERED OTP: $entered");
    print("📩 API OTP: $_otpFromApi");

    if (entered != _otpFromApi) {
      _msg("Invalid OTP");
      return;
    }

    Get.to(() => ChangePasswordScreen(
      userId: _userId,
      otp: entered, // ✅ old_password will be OTP
    ));
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF061B2B);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/bg.png", fit: BoxFit.cover),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            width: 58, // ✅ bigger tap + visible animation
                            height: 58,
                            child: Center(
                              child: Transform.scale(
                                scale: 1.5, // ✅ makes blue rotating line clearly visible
                                child: Lottie.asset(
                                  "assets/images/back_arrow.json",
                                  width: 42,
                                  height: 42,
                                  fit: BoxFit.contain,
                                  repeat: true,
                                  animate: true,
                                  // optional: better smoothness
                                  // frameRate: FrameRate.max,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Image.asset(
                          "assets/images/logo.png",
                          width: 85,
                          height: 85,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 155),
                    const Text(
                      "Enter Code",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Enter Code sent to your mail",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) {
                        return _OtpBox(
                          controller: ctrls[i],
                          focusNode: nodes[i],
                          onChanged: (v) => _onChanged(i, v),
                          onBackspace: () => _onBackspace(i),
                        );
                      }),
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                          children: [
                            const TextSpan(text: "Didn't Get Code? "),
                            TextSpan(
                              text: "Resend",
                              style: const TextStyle(
                                color: cyan,
                                fontWeight: FontWeight.w900,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer:
                              TapGestureRecognizer()..onTap = _resendOtp,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),

                    // ✅ Verify Button (NO UI CHANGE)
                    SizedBox(
                      width: double.infinity,
                      height: 66,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isLoading ? null : _verifyAndGoNext,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                  child: Lottie.asset(
                                    "assets/images/Verify_Button.json",
                                    fit: BoxFit.contain,
                                    repeat: true,
                                    animate: true,
                                  ),
                                ),
                                if (isLoading)
                                  Container(
                                    color: Colors.black.withOpacity(0.25),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 26,
                                        height: 26,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.6,
                                          valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    const boxColor = Color(0xFF0A2235);

    return SizedBox(
      width: 52,
      height: 52,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: boxColor.withOpacity(0.55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.10),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              counterText: "",
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
