import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:social_saver/Authentication%20Screens/enter_code_screen.dart';
import 'package:social_saver/services/forgot_password_service.dart';

class VerifyIdentityScreen extends StatefulWidget {
  const VerifyIdentityScreen({super.key});

  @override
  State<VerifyIdentityScreen> createState() => _VerifyIdentityScreenState();
}

class _VerifyIdentityScreenState extends State<VerifyIdentityScreen> {
  static const cyan = Color(0xFF2CC7FF);

  final emailCtrl = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  // ✅ Same app style snackbar (dark + cyan border)
  void _showMsg(String msg) {
    if (!mounted) return;
    if (msg.trim().isEmpty) return;

    final snack = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(seconds: 3),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A2235).withOpacity(0.95),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cyan.withOpacity(0.75), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cyan.withOpacity(0.12),
                border: Border.all(color: cyan.withOpacity(0.5)),
              ),
              child:
              const Icon(Icons.info_outline_rounded, color: cyan, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.2,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snack);
  }

  Future<void> _sendOtp() async {
    if (isLoading) return;

    final email = emailCtrl.text.trim();
    if (email.isEmpty) {
      _showMsg("Please enter email address");
      return;
    }

    setState(() => isLoading = true);

    final result = await ForgotPasswordService.sendOtp(email);

    setState(() => isLoading = false);

    final success = result["success"] == true;
    final message = (result["message"] ?? "").toString();

    if (success) {
      final data = result["data"];
      final userId = (data?["user_id"] ?? 0);
      final otp = (data?["otp"] ?? "").toString();
      final apiEmail = (data?["email"] ?? email).toString();

      if (userId == 0 || otp.isEmpty) {
        if (message.isNotEmpty) _showMsg(message);
        return;
      }

      // ✅ Optional: show message before next screen
      if (message.isNotEmpty) _showMsg(message);

      Get.to(() => EnterCodeScreen(
        email: apiEmail,
        userId: int.tryParse(userId.toString()) ?? 0,
        serverOtp: otp,
      ));
    } else {
      if (message.isNotEmpty) _showMsg(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF061B2B);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/bg.png",
            fit: BoxFit.cover,
          ),
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

                    // ✅ Top Row (Back JSON + Logo)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            width: 58,
                            height: 58,
                            child: Center(
                              child: Transform.scale(
                                scale: 1.5,
                                child: Lottie.asset(
                                  "assets/images/back_arrow.json",
                                  width: 42,
                                  height: 42,
                                  fit: BoxFit.contain,
                                  repeat: true,
                                  animate: true,
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

                    const SizedBox(height: 110),

                    const Text(
                      "Verify Your Identity",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Please enter your mail to verify your identity",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _GlassField(
                      child: TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Email Address",
                          hintStyle: TextStyle(color: Colors.white60),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 66,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isLoading ? null : _sendOtp,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                  child: Lottie.asset(
                                    "assets/images/Send_Code_Button.json",
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

                    const SizedBox(height: 40),
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

class _GlassField extends StatelessWidget {
  final Widget child;
  const _GlassField({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 57,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFF0A2235).withOpacity(0.55),
        border: Border.all(
          color: const Color(0xFF2CC7FF).withOpacity(0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2CC7FF).withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
