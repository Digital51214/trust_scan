import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:social_saver/Authentication%20Screens/signin_screen.dart';

import '../Services/forgot_password_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  final int userId;
  final String otp; // (screen flow me aa raha hai, but reset api me use nahi)

  const ChangePasswordScreen({
    super.key,
    required this.userId,
    required this.otp,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  bool obscure1 = true;
  bool obscure2 = true;
  bool isLoading = false;

  @override
  void dispose() {
    newPassCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }

  void _showMsg(String msg) {
    if (msg.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _resetPassword() async {
    if (isLoading) return;

    final newPass = newPassCtrl.text;
    final confirm = confirmPassCtrl.text;

    if (newPass.isEmpty || confirm.isEmpty) {
      _showMsg("Please enter password");
      return;
    }
    if (newPass != confirm) {
      _showMsg("Passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    print("🟦 RESET PASSWORD BUTTON PRESSED");
    print("🆔 USER ID: ${widget.userId}");
    print("🔐 NEW PASSWORD: $newPass");

    final result = await ForgotPasswordService.resetPassword(
      userId: widget.userId,
      newPassword: newPass,
    );

    print("✅ RESET PASSWORD RESULT MAP: $result");

    setState(() => isLoading = false);

    final success = result["success"] == true;
    final message = (result["message"] ?? "").toString();

    if (success) {
      if (message.isNotEmpty) _showMsg(message);
      Get.offAll(() => const SignInScreen());
    } else {
      if (message.isNotEmpty) _showMsg(message); // ✅ API error only
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
                    const SizedBox(height: 180),
                    const Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Enter Your New Password!",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 26),

                    _GlassField(
                      child: TextField(
                        controller: newPassCtrl,
                        obscureText: obscure1,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "New Password",
                          hintStyle: const TextStyle(color: Colors.white60),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => obscure1 = !obscure1),
                            icon: const Icon(
                              Icons.remove_red_eye_outlined,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    _GlassField(
                      child: TextField(
                        controller: confirmPassCtrl,
                        obscureText: obscure2,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Confirm Password",
                          hintStyle: const TextStyle(color: Colors.white60),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => obscure2 = !obscure2),
                            icon: const Icon(
                              Icons.remove_red_eye_outlined,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ✅ SAME BUTTON UI + LOADER OVERLAY
                    SizedBox(
                      width: double.infinity,
                      height: 66,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isLoading ? null : _resetPassword,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                  child: Lottie.asset(
                                    "assets/images/Change_Password.json",
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
