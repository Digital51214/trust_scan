import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_saver/session/session_controller.dart';

import '../Authentication Screens/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF061B2B);
    const cyan = Color(0xFF2CC7FF);

    final session = SessionController.instance;

    ImageProvider _profileProvider(String b64) {
      try {
        final clean = b64.trim();
        if (clean.isEmpty) {
          return const AssetImage("assets/images/profile.jpg");
        }
        return MemoryImage(base64Decode(clean));
      } catch (e) {
        print("❌ PROFILE IMAGE DECODE ERROR: $e");
        return const AssetImage("assets/images/profile.jpg");
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // because bottom nav overlay
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

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),

                  const Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ✅ Profile Image (SESSION BASED)
                  Center(
                    child: Container(
                      width: 118,
                      height: 118,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: cyan, width: 3),
                      ),
                      child: ClipOval(
                        child: Obx(() {
                          final b64 = session.profileImageBase64.value;
                          return Image(
                            image: _profileProvider(b64),
                            fit: BoxFit.cover,
                          );
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Name + Email from Session
                  Center(
                    child: Column(
                      children: [
                        Obx(() {
                          final name = session.name.value.trim();
                          return Text(
                            name.isEmpty ? "User" : name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          );
                        }),
                        const SizedBox(height: 4),
                        Obx(() {
                          final email = session.email.value.trim();
                          return Text(
                            email.isEmpty ? "-" : email,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ✅ Edit Profile Tile (wait result)
                  _ProfilePillTile(
                    title: "Edit Profile",
                    onTap: () async {
                      final updated = await Get.to(() => const EditProfileScreen());
                      print("🟩 BACK FROM EDIT PROFILE -> updated=$updated");
                      // Obx will auto-update UI after session changes
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

/* ===================== PILL TILE ===================== */

class _ProfilePillTile extends StatelessWidget {
  const _ProfilePillTile({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withOpacity(0.10),
            width: 1,
          ),
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
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.white.withOpacity(0.75),
            ),
          ],
        ),
      ),
    );
  }
}
