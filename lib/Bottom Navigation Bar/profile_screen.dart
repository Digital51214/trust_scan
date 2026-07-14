import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_saver/Bottom%20Navigation%20Bar/video_background.dart';
import 'package:social_saver/session/session_controller.dart';

import '../Authentication Screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF2CC7FF);
    final session = SessionController.instance;

    ImageProvider profileProvider(String b64) {
      try {
        final clean = b64.trim();
        if (clean.isEmpty) return const AssetImage("assets/images/profile.jpg");
        return MemoryImage(base64Decode(clean));
      } catch (_) {
        return const AssetImage("assets/images/profile.jpg");
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Video background ──────────────────────────────────
          const Positioned.fill(child: VideoBackground()),

          // ── UI content ────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "AI Profile",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF37C8FF)
                          .withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFF37C8FF)
                            .withOpacity(0.18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF37C8FF)
                              .withOpacity(0.06),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 13,
                          color: Color(0xFF37C8FF),
                        ),
                        SizedBox(width: 6),
                        Text(
                          "AI Edit Profile",
                          style: TextStyle(
                            color: Color(0xFFC7F7FF),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                        Border.all(color: cyan.withOpacity(0.4), width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: cyan, width: 2.5),
                          ),
                          child: ClipOval(
                            child: Obx(() => Image(
                              image: profileProvider(
                                  session.profileImageBase64.value),
                              fit: BoxFit.cover,
                            )),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Obx(() => Text(
                          session.name.value.isEmpty
                              ? "User"
                              : session.name.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                        const SizedBox(height: 6),
                        Obx(() => Text(
                          session.email.value,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _ProfilePillTile(
                    icon: Icons.tune_rounded,
                    title: "Edit Profile",
                    subtitle: "Update your name, photo and details",
                    onTap: () async {
                      await Get.to(() => const EditProfileScreen());
                    },
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

/* ===================== FUTURISTIC GLASSY TILE ===================== */

class _ProfilePillTile extends StatelessWidget {
  const _ProfilePillTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF2CC7FF);
    final effectiveIconColor = iconColor ?? cyan;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(.12)),
              boxShadow: [
                BoxShadow(
                  color: cyan.withOpacity(.12),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: effectiveIconColor.withOpacity(.12),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(.55),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.white.withOpacity(.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}