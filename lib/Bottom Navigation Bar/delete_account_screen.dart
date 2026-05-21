import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:social_saver/Authentication Screens/signin_screen.dart';
import 'package:social_saver/session/session_controller.dart';
import 'package:social_saver/services/delete_account_service.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  static const bg = Color(0xFF061B2B);
  static const cyan = Color(0xFF2CC7FF);
  static const red = Color(0xFFFF3B3B);

  bool _isDeleting = false;

  Future<void> _deleteAccount() async {
    if (_isDeleting) return;

    setState(() {
      _isDeleting = true;
    });

    debugPrint("========================================");
    debugPrint("🧠 DELETE ACCOUNT PROCESS STARTED");
    debugPrint("⏳ Loader started");
    debugPrint("========================================");

    if (!Get.isRegistered<SessionController>()) {
      debugPrint("❌ SessionController is not registered");

      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      _showErrorSnackbar(
        title: "Session Error",
        message: "Session not found. Please login again.",
      );

      return;
    }

    final int currentUserId = SessionController.instance.userId.value;

    debugPrint("👤 Current Session User ID: $currentUserId");

    if (currentUserId == 0) {
      debugPrint("❌ User ID not found in session");

      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      _showErrorSnackbar(
        title: "Session Error",
        message: "User ID not found. Please login again.",
      );

      return;
    }

    final result = await DeleteAccountService.deleteAccount(
      userId: currentUserId,
    );

    if (!mounted) return;

    setState(() {
      _isDeleting = false;
    });

    debugPrint("🛑 Loader stopped");

    if (result.success) {
      debugPrint("✅ Account deleted successfully");
      debugPrint("🧹 Clearing local session...");

      SessionController.instance.clearSession();

      debugPrint("✅ Session cleared");
      debugPrint("🚪 Navigating to SignInScreen");

      Get.snackbar(
        "Account Deleted",
        result.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: red.withOpacity(0.95),
        colorText: Colors.white,
        margin: const EdgeInsets.all(14),
        borderRadius: 14,
        duration: const Duration(seconds: 2),
        icon: const Icon(
          Icons.check_circle_rounded,
          color: Colors.white,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 700));

      Get.offAll(() => const SignInScreen());
    } else {
      debugPrint("❌ Account delete failed");
      debugPrint("❌ Message: ${result.message}");

      _showErrorSnackbar(
        title: "Delete Failed",
        message: result.message,
      );
    }
  }

  void _showErrorSnackbar({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF0A2235),
      colorText: Colors.white,
      margin: const EdgeInsets.all(14),
      borderRadius: 14,
      borderColor: red.withOpacity(0.45),
      borderWidth: 1.2,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.error_rounded,
        color: red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D5E7D),
                  bg,
                  Color(0xFF040F1D),
                ],
              ),
            ),
          ),

          // Red AI Glow Layer
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 1.2,
                colors: [
                  red.withOpacity(0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _isDeleting ? null : () => Get.back(),
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
                                animate: !_isDeleting,
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

                  const SizedBox(height: 30),

                  // Warning Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: red.withOpacity(0.25),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 13,
                          color: red,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Critical Action",
                          style: TextStyle(
                            color: Color(0xFFFFB3B3),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Delete Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: red.withOpacity(0.35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: red.withOpacity(0.18),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        "assets/images/delete.png",
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    "Delete Your Account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Deleting your account is permanent. All your data will be removed and you won’t be able to recover it.",
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.72),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Delete Button
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isDeleting
                              ? null
                              : () => _confirmDelete(context),
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: _isDeleting ? 0.35 : 1,
                                child: Lottie.asset(
                                  "assets/images/Delete_Buttons.json",
                                  fit: BoxFit.contain,
                                  repeat: true,
                                  animate: !_isDeleting,
                                ),
                              ),

                              if (_isDeleting)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 26,
                                      height: 26,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.8,
                                        color: Colors.white,
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

                  const Spacer(),
                ],
              ),
            ),
          ),

          // Full Screen Loader
          if (_isDeleting)
            Container(
              color: Colors.black.withOpacity(0.40),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A2235),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: red.withOpacity(0.40),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: red.withOpacity(0.25),
                        blurRadius: 22,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 34,
                        height: 34,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: red,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "Deleting Account...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Please wait while we securely remove your data.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: !_isDeleting,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A2235),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: red.withOpacity(.40),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: red.withOpacity(0.25),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: red.withOpacity(0.12),
                    border: Border.all(
                      color: red.withOpacity(0.40),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: red,
                    size: 34,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Confirm Deletion",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  "This action will permanently delete your account. Do you want to continue?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.2,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(.70),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: const StadiumBorder(),
                          side: BorderSide(
                            color: Colors.white.withOpacity(.18),
                            width: 1,
                          ),
                          foregroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        onPressed: _isDeleting ? null : () => Get.back(),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: red,
                          disabledBackgroundColor: red.withOpacity(0.45),
                          shape: const StadiumBorder(),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        onPressed: _isDeleting
                            ? null
                            : () {
                          debugPrint("🗑️ Delete confirmation accepted");
                          Get.back();
                          _deleteAccount();
                        },
                        child: const Text(
                          "Delete",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}