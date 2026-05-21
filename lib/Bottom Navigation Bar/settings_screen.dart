import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:social_saver/Authentication Screens/signin_screen.dart';
import 'package:social_saver/Bottom%20Navigation%20Bar/video_background.dart';
import 'package:social_saver/session/session_controller.dart';

import 'delete_account_screen.dart';
import 'help_support.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  static const bg = Color(0xFF020C18);
  static const cyan = Color(0xFF00E5FF);
  static const red = Color(0xFFFF3B3B);

  bool notifOn = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      notifOn = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);

    if (!mounted) return;

    setState(() {
      notifOn = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const VideoBackground(),

          AnimatedContainer(
            duration: const Duration(seconds: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.22),
                  Colors.transparent,
                  const Color(0xFF061B2B).withOpacity(0.22),
                  const Color(0xFF061B2B).withOpacity(0.72),
                ],
                stops: const [0.0, 0.28, 0.62, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  const Text(
                    "AI Settings",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _PillTile(
                    title: "Notifications",
                    trailing: Switch(
                      value: notifOn,
                      activeColor: cyan,
                      activeTrackColor: cyan.withOpacity(.30),
                      inactiveThumbColor: Colors.white70,
                      inactiveTrackColor: Colors.white24,
                      onChanged: (v) => _saveNotificationSetting(v),
                    ),
                    onTap: () {
                      _saveNotificationSetting(!notifOn);
                    },
                  ),

                  const SizedBox(height: 14),

                  _PillTile(
                    title: "Help Center",
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withOpacity(.7),
                      size: 18,
                    ),
                    onTap: () {
                      Get.to(() => const HelpAndSupportScreens());
                    },
                  ),

                  const SizedBox(height: 14),

                  _PillTile(
                    title: "Delete Account",
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withOpacity(.7),
                      size: 18,
                    ),
                    onTap: () {
                      Get.to(() => const DeleteAccountScreen());
                    },
                  ),

                  const SizedBox(height: 30),

                  const SizedBox(height: 16),

                  _pulseButton(
                    child: Lottie.asset(
                      "assets/images/Log_Out.json",
                      fit: BoxFit.contain,
                      repeat: true,
                      animate: true,
                    ),
                    onTap: () => _logoutDialog(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pulseButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.05),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, value, childWidget) {
        return Transform.scale(
          scale: value,
          child: childWidget,
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 70,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: cyan.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  void _logoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (_) => _ThemedDialog(
        title: "Logout",
        message: "Disconnect from AI session?",
        icon: Icons.logout,
        iconColor: cyan,
        primaryText: "Yes",
        primaryColor: cyan,
        onPrimary: () {
          Get.back();

          if (Get.isRegistered<SessionController>()) {
            SessionController.instance.clearSession();
          }

          Get.offAll(() => const SignInScreen());
        },
      ),
    );
  }

  void _deleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.70),
      builder: (_) => _ThemedDialog(
        title: "Delete Account",
        message: "This will erase all AI data permanently.",
        icon: Icons.delete_forever,
        iconColor: red,
        primaryText: "Delete",
        primaryColor: red,
        onPrimary: () {
          Get.back();

          if (Get.isRegistered<SessionController>()) {
            SessionController.instance.clearSession();
          }

          Get.offAll(() => const SignInScreen());
        },
      ),
    );
  }
}

/* ===================== FUTURISTIC TILE ===================== */

class _PillTile extends StatelessWidget {
  const _PillTile({
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  final String title;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00E5FF);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: cyan.withOpacity(.1)),
              boxShadow: [
                BoxShadow(
                  color: cyan.withOpacity(.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ===================== FUTURISTIC DIALOG ===================== */

class _ThemedDialog extends StatelessWidget {
  const _ThemedDialog({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.primaryText,
    required this.primaryColor,
    required this.onPrimary,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String primaryText;
  final Color primaryColor;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF021826).withOpacity(.9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: primaryColor.withOpacity(.4)),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(.5),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 40),

                const SizedBox(height: 10),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: const Text("No"),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                        ),
                        onPressed: onPrimary,
                        child: Text(primaryText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}