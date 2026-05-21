import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';

import 'package:social_saver/Authentication Screens/signup_screen.dart';
import 'package:social_saver/Authentication Screens/verify_identity_screen.dart';
import 'package:social_saver/services/login_service.dart';
import 'package:social_saver/session/session_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool rememberMe = false;
  bool obscure = true;
  bool isLoading = false;

  // Field error messages
  String? emailError;
  String? passError;

  final _box = GetStorage();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  void _showMsg(String msg, {bool isError = true}) {
    if (msg.trim().isEmpty) return;
    Get.snackbar(
      isError ? "Error" : "Success",
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
      isError ? Colors.red.shade900.withOpacity(0.92) : Colors.green.shade800.withOpacity(0.92),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
        color: Colors.white,
      ),
    );
  }

  bool _isValidEmail(String email) => GetUtils.isEmail(email.trim());

  bool _validateFields() {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;
    bool valid = true;

    setState(() {
      // Email checks
      if (email.isEmpty) {
        emailError = "Email address is required";
        valid = false;
      } else if (!_isValidEmail(email)) {
        emailError = "Please enter a valid email address";
        valid = false;
      } else {
        emailError = null;
      }

      // Password checks
      if (pass.isEmpty) {
        passError = "Password is required";
        valid = false;
      } else if (pass.length < 6) {
        passError = "Password must be at least 6 characters";
        valid = false;
      } else {
        passError = null;
      }
    });

    return valid;
  }

  Map<String, dynamic>? _extractUser(dynamic result) {
    if (result is! Map) return null;
    final a = result["data"];
    if (a is Map) {
      final u1 = a["user"];
      if (u1 is Map) return Map<String, dynamic>.from(u1);
      final b = a["data"];
      if (b is Map) {
        final u2 = b["user"];
        if (u2 is Map) return Map<String, dynamic>.from(u2);
      }
    }
    final u3 = result["user"];
    if (u3 is Map) return Map<String, dynamic>.from(u3);
    return null;
  }

  String _parseErrorMessage(Map result) {
    final message = (result["message"] ?? "").toString().toLowerCase().trim();
    final errors = result["errors"];

    // ── Network / server errors ──
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

    if (message.contains("404")) {
      return "Service not found. Please contact support.";
    }

    // ── Auth errors ──
    if (message.contains("invalid credentials") ||
        message.contains("wrong password") ||
        message.contains("incorrect password") ||
        message.contains("password is incorrect")) {
      setState(() => passError = "Incorrect password. Please try again.");
      return "Incorrect password. Please try again.";
    }

    if (message.contains("user not found") ||
        message.contains("no account") ||
        message.contains("email not found") ||
        message.contains("not registered")) {
      setState(() => emailError = "No account found with this email.");
      return "No account found with this email. Please sign up first.";
    }

    if (message.contains("account disabled") ||
        message.contains("account suspended") ||
        message.contains("blocked")) {
      return "Your account has been suspended. Please contact support.";
    }

    if (message.contains("too many") || message.contains("rate limit")) {
      return "Too many login attempts. Please wait a moment and try again.";
    }

    // ── Validation errors from backend ──
    if (errors is Map) {
      final msgs = errors.values
          .map((e) => e is List ? e.first.toString() : e.toString())
          .join("\n");
      if (msgs.isNotEmpty) return msgs;
    }

    // ── Fallback: return raw message if not empty ──
    if (message.isNotEmpty) {
      return result["message"].toString();
    }

    return "Login failed. Please try again.";
  }

  Future<void> _login() async {
    if (isLoading) return;

    // Clear previous errors
    setState(() {
      emailError = null;
      passError = null;
    });

    if (!_validateFields()) return;

    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    setState(() => isLoading = true);

    Map<String, dynamic> result = {};

    try {
      result = await LoginService.login(email: email, password: pass);
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
    _showMsg("Login successful! Welcome back.", isError: false);

    final user = _extractUser(result);

    if (user != null) {
      if (!Get.isRegistered<SessionController>()) {
        Get.put(SessionController(), permanent: true);
      }
      SessionController.instance.createSessionFromUser(user);
      _box.write("onboardingSeen", true);
      Get.offAllNamed('/home');
    } else {
      _showMsg("Login successful but user data missing. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B2B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: ConstrainedBox(
                    constraints:
                    BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 44),
                        Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 244,
                            height: 244,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Welcome Back! Enter Your Account Details",
                          style:
                          TextStyle(fontSize: 13.5, color: Colors.white70),
                        ),
                        const SizedBox(height: 26),

                        // ── Email field ──
                        _GlassField(
                          hasError: emailError != null,
                          child: TextField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) {
                              if (emailError != null) {
                                setState(() => emailError = null);
                              }
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

                        // ── Password field ──
                        _GlassField(
                          hasError: passError != null,
                          child: TextField(
                            controller: passCtrl,
                            obscureText: obscure,
                            textInputAction: TextInputAction.done,
                            onChanged: (_) {
                              if (passError != null) {
                                setState(() => passError = null);
                              }
                            },
                            onSubmitted: (_) => _login(),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Password",
                              hintStyle:
                              const TextStyle(color: Colors.white60),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 16),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => obscure = !obscure),
                                icon: Icon(
                                  obscure
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

                        // ── Remember me + Forgot password ──
                        Row(
                          children: [
                            Theme(
                              data: Theme.of(context).copyWith(
                                checkboxTheme: CheckboxThemeData(
                                  shape: const CircleBorder(),
                                  side: const BorderSide(
                                      color: Colors.white54, width: 1),
                                ),
                              ),
                              child: Checkbox(
                                value: rememberMe,
                                onChanged: (v) =>
                                    setState(() => rememberMe = v ?? false),
                                activeColor: const Color(0xFF2CC7FF),
                                checkColor: Colors.black,
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text("Remember Me",
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 12)),
                            const Spacer(),
                            TextButton(
                              onPressed: () =>
                                  Get.to(() => const VerifyIdentityScreen()),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                "Forget Password?",
                                style: TextStyle(
                                  color: Color(0xFF2CC7FF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // ── Login button ──
                        LayoutBuilder(
                          builder: (context, cts) {
                            final w = cts.maxWidth;
                            final h = w / (333 / 60);
                            final r = h / 2;
                            return SizedBox(
                              width: w,
                              height: h,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(r),
                                child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                        onTap: isLoading ? null : _login,
                                        borderRadius: BorderRadius.circular(r),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                          Lottie.asset(
                                          "assets/images/Sign_in_button.json",
                                          fit: BoxFit.cover,
                                          repeat: true,
                                          animate: true,
                                        ),
                                        if (isLoading)
                                    Container(
                                color: Colors.black
                                    .withOpacity(0.25),
                                child: const Center(
                                  child: SizedBox(
                                    width: 26,
                                    height: 26,
                                    child:
                                    CircularProgressIndicator(
                                        strokeWidth: 2.6,
                                      valueColor: const AlwaysStoppedAnimation(Colors.white),)
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

                        const SizedBox(height: 40),

                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                const TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                  text: "Sign Up",
                                  style: const TextStyle(
                                    color: Color(0xFF2CC7FF),
                                    fontWeight: FontWeight.w800,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFF2CC7FF),
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap =
                                        () => Get.to(() => const SignUpScreen()),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error text widget ──
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