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

  final _box = GetStorage();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
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

  Map<String, dynamic>? _extractUser(dynamic result) {
    if (result is! Map) return null;

    // ✅ try common paths
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

  Future<void> _login() async {
    if (isLoading) return;

    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      _showMsg("Please enter login details");
      return;
    }

    setState(() => isLoading = true);

    final result = await LoginService.login(email: email, password: pass);

    final success = result["success"] == true;
    final message = (result["message"] ?? "").toString();

    setState(() => isLoading = false);

    if (!success) {
      if (message.isNotEmpty) {
        Get.snackbar(
          "Error",
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black.withOpacity(0.75),
          colorText: Colors.white,
        );
      }
      return;
    }

    // ✅ success
    if (message.isNotEmpty) {
      Get.snackbar(
        "Success",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black.withOpacity(0.75),
        colorText: Colors.white,
      );
    }

    // ✅ extract user robustly
    final user = _extractUser(result);
    print("👤 LOGIN USER DATA (extracted): $user");

    if (user != null) {
      if (!Get.isRegistered<SessionController>()) {
        Get.put(SessionController(), permanent: true);
      }
      SessionController.instance.createSessionFromUser(user);

      // ✅ mark onboarding done
      _box.write("onboardingSeen", true);

      // ✅ go home
      Get.offAllNamed('/home');
    } else {
      // if backend success but user missing
      Get.snackbar(
        "Error",
        "Login success but user data missing",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black.withOpacity(0.75),
        colorText: Colors.white,
      );
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
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                          style: TextStyle(fontSize: 13.5, color: Colors.white70),
                        ),
                        const SizedBox(height: 26),

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
                              contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        _GlassField(
                          child: TextField(
                            controller: passCtrl,
                            obscureText: obscure,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _login(),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Password",
                              hintStyle: const TextStyle(color: Colors.white60),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => obscure = !obscure),
                                icon: Icon(
                                  obscure ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Theme(
                              data: Theme.of(context).copyWith(
                                checkboxTheme: CheckboxThemeData(
                                  shape: const CircleBorder(),
                                  side: const BorderSide(color: Colors.white54, width: 1),
                                ),
                              ),
                              child: Checkbox(
                                value: rememberMe,
                                onChanged: (v) => setState(() => rememberMe = v ?? false),
                                activeColor: const Color(0xFF2CC7FF),
                                checkColor: Colors.black,
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text("Remember Me", style: TextStyle(color: Colors.white60, fontSize: 12)),
                            const Spacer(),
                            TextButton(
                              onPressed: () => Get.to(() => const VerifyIdentityScreen()),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                                            color: Colors.black.withOpacity(0.25),
                                            child: const Center(
                                              child: SizedBox(
                                                width: 26,
                                                height: 26,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.6,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                                    ..onTap = () => Get.to(() => const SignUpScreen()),
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
        border: Border.all(color: const Color(0xFF2CC7FF).withOpacity(0.35), width: 1),
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
