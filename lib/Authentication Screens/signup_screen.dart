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

  // Field errors
  String? nameError;
  String? emailError;
  String? passError;
  String? cPassError;

  @override
  void dispose() {
    userCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    cPassCtrl.dispose();
    super.dispose();
  }

  void _showMsg(String msg, {bool isError = true}) {
    if (msg.trim().isEmpty) return;
    Get.snackbar(
      isError ? "Error" : "Success",
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? Colors.red.shade900.withOpacity(0.92)
          : Colors.green.shade800.withOpacity(0.92),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError
            ? Icons.error_outline_rounded
            : Icons.check_circle_outline_rounded,
        color: Colors.white,
      ),
    );
  }

  bool _isValidEmail(String email) => GetUtils.isEmail(email.trim());

  bool _isStrongPassword(String pass) {
    final hasMinLen = pass.length >= 8;
    final hasSpecial = RegExp(r'[^\w\s]').hasMatch(pass);
    return hasMinLen && hasSpecial;
  }

  bool _validateFields() {
    final name = userCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;
    final cPass = cPassCtrl.text;
    bool valid = true;

    setState(() {
      // Name
      if (name.isEmpty) {
        nameError = "Username is required";
        valid = false;
      } else if (name.length < 3) {
        nameError = "Username must be at least 3 characters";
        valid = false;
      } else {
        nameError = null;
      }

      // Email
      if (email.isEmpty) {
        emailError = "Email address is required";
        valid = false;
      } else if (!_isValidEmail(email)) {
        emailError = "Please enter a valid email address";
        valid = false;
      } else {
        emailError = null;
      }

      // Password
      if (pass.isEmpty) {
        passError = "Password is required";
        valid = false;
      } else if (pass.length < 8) {
        passError = "Password must be at least 8 characters";
        valid = false;
      } else if (!RegExp(r'[^\w\s]').hasMatch(pass)) {
        passError = "Password must contain at least 1 special character (!@#\$...)";
        valid = false;
      } else {
        passError = null;
      }

      // Confirm password
      if (cPass.isEmpty) {
        cPassError = "Please confirm your password";
        valid = false;
      } else if (pass != cPass) {
        cPassError = "Passwords do not match";
        valid = false;
      } else {
        cPassError = null;
      }
    });

    // Terms check
    if (!agree) {
      _showMsg("Please agree to Terms & Conditions and Privacy Policy");
      return false;
    }

    return valid;
  }

  String _parseErrorMessage(Map result) {
    final message = (result["message"] ?? "").toString().toLowerCase().trim();
    final errors = result["errors"];

    // ── Network errors ──
    if (message.contains("socket") ||
        message.contains("connection") ||
        message.contains("network") ||
        message.contains("timeout") ||
        message.contains("unreachable") ||
        message.contains("failed host lookup") ||
        message.contains("no internet")) {
      return "No internet connection. Please check your WiFi or mobile data.";
    }

    if (message.contains("500") || message.contains("server error")) {
      return "Server error. Please try again later.";
    }

    // ── Already existing email ──
    if (message.contains("already") ||
        message.contains("exists") ||
        message.contains("duplicate") ||
        message.contains("taken") ||
        message.contains("registered") ||
        message.contains("email already") ||
        message.contains("already used")) {
      setState(() =>
      emailError = "This email is already registered. Please sign in.");
      return "This email is already registered. Please sign in instead.";
    }

    // ── Validation errors from backend ──
    if (errors is Map) {
      final msgs = errors.values
          .map((e) => e is List ? e.first.toString() : e.toString())
          .join("\n");
      if (msgs.isNotEmpty) return msgs;
    }

    if (message.isNotEmpty) return result["message"].toString();

    return "Sign up failed. Please try again.";
  }

  Future<void> _signup() async {
    if (isLoading) return;

    // Clear all errors
    setState(() {
      nameError = null;
      emailError = null;
      passError = null;
      cPassError = null;
    });

    if (!_validateFields()) return;

    final name = userCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    setState(() => isLoading = true);

    Map<String, dynamic> result = {};

    try {
      result = await SignupService.signup(
        name: name,
        email: email,
        password: pass,
      );
    } catch (e) {
      setState(() => isLoading = false);
      final err = e.toString().toLowerCase();
      if (err.contains("socket") ||
          err.contains("connection") ||
          err.contains("network") ||
          err.contains("timeout") ||
          err.contains("failed host lookup")) {
        _showMsg("No internet connection. Please check your WiFi or mobile data.");
      } else {
        _showMsg("Something went wrong. Please try again.");
      }
      return;
    }

    setState(() => isLoading = false);

    final success = result["success"] == true;

    if (!success) {
      final errMsg = _parseErrorMessage(result);
      _showMsg(errMsg);
      return;
    }

    // ── Success ──
    _showMsg("Account created successfully! Welcome.", isError: false);

    final user = result["data"]?["user"];

    if (user is Map<String, dynamic>) {
      if (!Get.isRegistered<SessionController>()) {
        Get.put(SessionController());
      }
      SessionController.instance.createSessionFromUser(user);
    }

    Get.offAll(() => const BottomNavScreen());
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF061B2B);
    const cyan = Color(0xFF2CC7FF);
    const double gifRatio = 333 / 60;

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

                  // ── Username ──
                  _GlassField(
                    hasError: nameError != null,
                    child: TextField(
                      controller: userCtrl,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {
                        if (nameError != null) setState(() => nameError = null);
                      },
                      onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Username",
                        hintStyle: TextStyle(color: Colors.white60),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                      ),
                    ),
                  ),
                  if (nameError != null) _ErrorText(nameError!),
                  const SizedBox(height: 14),

                  // ── Email ──
                  _GlassField(
                    hasError: emailError != null,
                    child: TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {
                        if (emailError != null) setState(() => emailError = null);
                      },
                      onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Email Address",
                        hintStyle: TextStyle(color: Colors.white60),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                      ),
                    ),
                  ),
                  if (emailError != null) _ErrorText(emailError!),
                  const SizedBox(height: 14),

                  // ── Password ──
                  _GlassField(
                    hasError: passError != null,
                    child: TextField(
                      controller: passCtrl,
                      obscureText: obscure1,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {
                        if (passError != null) setState(() => passError = null);
                        // Live confirm password check
                        if (cPassCtrl.text.isNotEmpty &&
                            cPassCtrl.text != passCtrl.text) {
                          setState(() =>
                          cPassError = "Passwords do not match");
                        } else if (cPassCtrl.text == passCtrl.text) {
                          setState(() => cPassError = null);
                        }
                      },
                      onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: const TextStyle(color: Colors.white60),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => obscure1 = !obscure1),
                          icon: Icon(
                            obscure1
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (passError != null) _ErrorText(passError!),
                  const SizedBox(height: 14),

                  // ── Confirm password ──
                  _GlassField(
                    hasError: cPassError != null,
                    child: TextField(
                      controller: cPassCtrl,
                      obscureText: obscure2,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) {
                        if (cPassCtrl.text == passCtrl.text) {
                          setState(() => cPassError = null);
                        } else {
                          setState(() =>
                          cPassError = "Passwords do not match");
                        }
                      },
                      onSubmitted: (_) => _signup(),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        hintStyle: const TextStyle(color: Colors.white60),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => obscure2 = !obscure2),
                          icon: Icon(
                            obscure2
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (cPassError != null) _ErrorText(cPassError!),
                  const SizedBox(height: 16),

                  // ── Terms ──
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
                              ? const Icon(Icons.check,
                              size: 13, color: Colors.black)
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
                                  ..onTap = () =>
                                      Get.to(() => const TermsConditionsScreen()),
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
                                  ..onTap = () =>
                                      Get.to(() => const PrivacyPolicyScreen()),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // ── Signup button ──
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
                                                Colors.white),
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
                              ..onTap = () => Get.back(),
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

// ── Error text ──
class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 14),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFFF5B5B), size: 13),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFF5B5B),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glass field ──
class _GlassField extends StatelessWidget {
  final Widget child;
  final bool hasError;
  const _GlassField({required this.child, this.hasError = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 57,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFF0A2235).withOpacity(0.55),
        border: Border.all(
          color: hasError
              ? const Color(0xFFFF5B5B).withOpacity(0.80)
              : const Color(0xFF2CC7FF).withOpacity(0.35),
          width: hasError ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasError
                ? const Color(0xFFFF5B5B).withOpacity(0.15)
                : const Color(0xFF2CC7FF).withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}