import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:social_saver/session/session_controller.dart';
import 'package:social_saver/services/edit_profile_service.dart';


import '../Bottom Navigation Bar/video_background.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  final session = SessionController.instance;

  late final TextEditingController nameCtrl;
  late final TextEditingController emailCtrl;

  final RxBool isLoading = false.obs;

  File? pickedImageFile;
  String pickedImageBase64 = "";

  late final AnimationController _ringCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: session.name.value);
    emailCtrl = TextEditingController(text: session.email.value);

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  ImageProvider _profileProvider() {
    try {
      if (pickedImageFile != null) return FileImage(pickedImageFile!);
      final b64 = session.profileImageBase64.value.trim();
      if (b64.isNotEmpty) return MemoryImage(base64Decode(b64));
      return const AssetImage("assets/images/profile.jpg");
    } catch (e) {
      return const AssetImage("assets/images/profile.jpg");
    }
  }

  void _showImagePickerSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        decoration: BoxDecoration(
          color: const Color(0xFF061B2B),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border.all(
            color: const Color(0xFF2CC7FF).withOpacity(0.14),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2CC7FF).withOpacity(0.08),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select Image",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.15,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Update your AI identity layer",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _SheetTile(
                icon: Icons.camera_alt_rounded,
                title: "Camera",
                onTap: () async {
                  Get.back();
                  await _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              _SheetTile(
                icon: Icons.photo_library_rounded,
                title: "Gallery",
                onTap: () async {
                  Get.back();
                  await _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border:
                    Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: false,
      ignoreSafeArea: false,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(source: source, imageQuality: 80);
      if (xfile == null) return;

      final file = File(xfile.path);
      final bytes = await file.readAsBytes();
      final b64 = base64Encode(bytes);

      setState(() {
        pickedImageFile = file;
        pickedImageBase64 = b64;
      });
    } catch (e) {
      Get.snackbar("Error", "Image pick failed: $e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _updateProfile() async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();

    if (name.isEmpty) {
      Get.snackbar("Error", "Name is required",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar("Error", "Enter valid email",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final userId = session.userId.value;
    if (userId == 0) {
      Get.snackbar("Error", "Session user not found",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;

    try {
      await EditProfileService.editProfile(
        userId: userId,
        name: name,
        imageBase64: pickedImageBase64,
      );

      final finalImageB64 = pickedImageBase64.isNotEmpty
          ? pickedImageBase64
          : session.profileImageBase64.value;

      session.createSessionFromUser({
        "id": userId,
        "name": name,
        "email": email,
        "level_id": session.levelId.value,
        "image": finalImageB64,
      });

      Get.snackbar("Success", "Profile updated",
          snackPosition: SnackPosition.BOTTOM);
      Get.back(result: true);
    } catch (e) {
      final msg = e.toString().replaceAll("Exception:", "").trim();
      Get.snackbar("Error", msg, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF2CC7FF);

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
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
              child: Column(
                children: [
                  // ── Back button ─────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(color: cyan.withOpacity(0.25)),
                          boxShadow: [
                            BoxShadow(
                              color: cyan.withOpacity(0.08),
                              blurRadius: 10,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Badge ───────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: cyan.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: cyan.withOpacity(0.18)),
                      boxShadow: [
                        BoxShadow(
                          color: cyan.withOpacity(0.06),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded,
                            size: 13, color: Color(0xFF2CC7FF)),
                        SizedBox(width: 6),
                        Text(
                          "AI Identity Editor",
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
                  const SizedBox(height: 28),

                  // ── Profile image ────────────────────────────
                  GestureDetector(
                    onTap: _showImagePickerSheet,
                    child: SizedBox(
                      width: 142,
                      height: 142,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          RotationTransition(
                            turns: _ringCtrl,
                            child: Container(
                              width: 142,
                              height: 142,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: cyan.withOpacity(0.42),
                                  width: 1.6,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: cyan.withOpacity(0.12),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 124,
                            height: 124,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: cyan, width: 2.8),
                              boxShadow: [
                                BoxShadow(
                                  color: cyan.withOpacity(0.25),
                                  blurRadius: 22,
                                  spreadRadius: 1.5,
                                ),
                              ],
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  cyan.withOpacity(0.20),
                                  Colors.white.withOpacity(0.04),
                                ],
                              ),
                            ),
                            child: ClipOval(
                              child: Image(
                                image: _profileProvider(),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: cyan,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: cyan.withOpacity(0.45),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Title ────────────────────────────────────
                  const Text(
                    "Refine AI Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Update your identity details for a sharper AI profile experience.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontSize: 12.8,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Fields ───────────────────────────────────
                  _InputField(controller: nameCtrl, hint: "Name"),
                  const SizedBox(height: 14),
                  _InputField(controller: emailCtrl, hint: "Email"),
                  const SizedBox(height: 30),

                  // ── Update button ────────────────────────────
                  Obx(() => AbsorbPointer(
                    absorbing: isLoading.value,
                    child: Opacity(
                      opacity: isLoading.value ? 0.65 : 1,
                      child: GestureDetector(
                        onTap: _updateProfile,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Lottie.asset(
                              "assets/images/Update_Button.json",
                              height: 60,
                              fit: BoxFit.contain,
                            ),
                            if (isLoading.value)
                              const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Input Field ───────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  const _InputField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF2CC7FF);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cyan.withOpacity(0.28)),
        color: const Color(0xFF0A2235).withOpacity(0.50),
        boxShadow: [
          BoxShadow(
            color: cyan.withOpacity(0.10),
            blurRadius: 16,
            spreadRadius: 0.5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: controller,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

// ── Sheet Tile ────────────────────────────────────────────────────────────────
class _SheetTile extends StatelessWidget {
  const _SheetTile(
      {required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF2CC7FF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cyan.withOpacity(0.14)),
          boxShadow: [
            BoxShadow(
              color: cyan.withOpacity(0.05),
              blurRadius: 12,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cyan.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cyan.withOpacity(0.35)),
              ),
              child: Icon(icon, color: cyan, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                letterSpacing: 0.12,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.white.withOpacity(0.65)),
          ],
        ),
      ),
    );
  }
}