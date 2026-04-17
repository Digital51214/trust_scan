import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:social_saver/Authentication%20Screens/privacy_policy_screen.dart';
import 'package:social_saver/Authentication%20Screens/terms_conditions_screen.dart';
import 'package:social_saver/Bottom%20Navigation%20Bar/bottom_nav_screen.dart';
import 'package:social_saver/services/signup_service.dart';
import 'package:social_saver/session/session_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final userCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final cPassCtrl = TextEditingController();

  bool obscure1 = true;
  bool obscure2 = true;
  bool agree = true;

  bool isLoading = false;

  @override
  void dispose() {
    userCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    cPassCtrl.dispose();
    super.dispose();
  }

  void _showMsg(String msg) {
    if (msg.trim().isEmpty) return;
    Get.snackbar(
      "Alert",
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.75),
      colorText: Colors.white,
    );
  }

  bool _isValidEmail(String email) {
    // using GetX helper (good enough for UI validation)
    return GetUtils.isEmail(email.trim());
  }

  bool _isStrongPassword(String pass) {
    // ✅ at least 8 chars and at least 1 special character
    // special chars: anything not letter/number
    final hasMinLen = pass.length >= 8;
    final hasSpecial = RegExp(r'[^\w\s]').hasMatch(pass); // special char
    return hasMinLen && hasSpecial;
  }

  Future<void> _signup() async {
    if (isLoading) return;

    final name = userCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;
    final cPass = cPassCtrl.text;

    // ✅ 1) Empty checks
    if (name.isEmpty || email.isEmpty || pass.isEmpty || cPass.isEmpty) {
      _showMsg("Please enter signup details");
      return;
    }

    // ✅ 2) Email validation
    if (!_isValidEmail(email)) {
      _showMsg("Please enter a valid email address");
      return;
    }

    // ✅ 3) Password rules
    if (!_isStrongPassword(pass)) {
      _showMsg("Password must be at least 8 characters and contain 1 special character");
      return;
    }

    // ✅ 4) Confirm password match
    if (pass != cPass) {
      _showMsg("Passwords do not match");
      return;
    }

    // ✅ 5) Terms agreement
    if (!agree) {
      _showMsg("Please agree to Terms & Conditions");
      return;
    }

    // ✅ After all validations → hit API
    setState(() => isLoading = true);

    print("🟦 SIGNUP BUTTON PRESSED");
    print("👤 Name: $name");
    print("📧 Email: $email");

    final result = await SignupService.signup(
      name: name,
      email: email,
      password: pass,
    );

    print("✅ SIGNUP RESULT MAP: $result");

    final success = result["success"] == true;
    final message = (result["message"] ?? "").toString();

    setState(() => isLoading = false);

    if (success) {
      if (message.isNotEmpty) {
        Get.snackbar(
          "Success",
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black.withOpacity(0.75),
          colorText: Colors.white,
        );
      }

      final user = result["data"]?["user"];
      print("👤 SIGNUP USER DATA: $user");

      if (user is Map<String, dynamic>) {
        if (!Get.isRegistered<SessionController>()) {
          Get.put(SessionController());
        }
        SessionController.instance.createSessionFromUser(user);
      }

      Get.offAll(() => const BottomNavScreen());
    } else {
      if (message.isNotEmpty) {
        Get.snackbar(
          "Error",
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black.withOpacity(0.75),
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF061B2B);
    const cyan = Color(0xFF2CC7FF);

    const double gifW = 333;
    const double gifH = 60;
    const double gifRatio = gifW / gifH;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      "assets/images/logo.png",
                      width: 244,
                      height: 244,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Welcome! Enter Details for account",
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 22),

                  _GlassField(
                    child: TextField(
                      controller: userCtrl,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Username",
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
                  const SizedBox(height: 14),

                  _GlassField(
                    child: TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
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
                  const SizedBox(height: 14),

                  _GlassField(
                    child: TextField(
                      controller: passCtrl,
                      obscureText: obscure1,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: const TextStyle(color: Colors.white60),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => obscure1 = !obscure1),
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
                      controller: cPassCtrl,
                      obscureText: obscure2,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _signup(),
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
                          onPressed: () => setState(() => obscure2 = !obscure2),
                          icon: const Icon(
                            Icons.remove_red_eye_outlined,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => agree = !agree),
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: agree ? cyan : Colors.transparent,
                            border: Border.all(
                              color: agree ? cyan : Colors.white38,
                              width: 1.3,
                            ),
                          ),
                          child: agree
                              ? const Icon(
                            Icons.check,
                            size: 13,
                            color: Colors.black,
                          )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 11.6,
                              color: Colors.white60,
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              const TextSpan(text: "I agree with all "),
                              TextSpan(
                                text: "Terms & Conditions",
                                style: const TextStyle(
                                  color: cyan,
                                  decoration: TextDecoration.underline,
                                  decorationColor: cyan,
                                  fontWeight: FontWeight.w700,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Get.to(() => const TermsConditionsScreen());
                                  },
                              ),
                              const TextSpan(text: " and "),
                              TextSpan(
                                text: "Privacy Policy",
                                style: const TextStyle(
                                  color: cyan,
                                  decoration: TextDecoration.underline,
                                  decorationColor: cyan,
                                  fontWeight: FontWeight.w700,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Get.to(() => const PrivacyPolicyScreen());
                                  },
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 22),

                  LayoutBuilder(
                    builder: (context, cts) {
                      final w = cts.maxWidth;
                      final h = w / gifRatio;
                      final r = h / 2;

                      return SizedBox(
                        width: w,
                        height: h,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(r),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isLoading ? null : _signup,
                              borderRadius: BorderRadius.circular(r),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Lottie.asset(
                                    "assets/images/Sign_Up_Button.json",
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                    repeat: true,
                                    animate: true,
                                    addRepaintBoundary: true,
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
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          const TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: "Sign In",
                            style: const TextStyle(
                              color: cyan,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.underline,
                              decorationColor: cyan,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.back();
                              },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),
                ],
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
