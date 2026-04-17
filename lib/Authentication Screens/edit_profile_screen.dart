import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import 'package:social_saver/session/session_controller.dart';
import 'package:social_saver/services/edit_profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final session = SessionController.instance;

  late final TextEditingController nameCtrl;
  late final TextEditingController emailCtrl;

  final RxBool isLoading = false.obs;

  File? pickedImageFile;
  String pickedImageBase64 = "";

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: session.name.value);
    emailCtrl = TextEditingController(text: session.email.value);

    print("🟦 EDIT PROFILE INIT");
    print("➡️ session id=${session.userId.value}");
    print("➡️ session name=${session.name.value}");
    print("➡️ session email=${session.email.value}");
    print("➡️ session imgLen=${session.profileImageBase64.value.length}");
  }

  @override
  void dispose() {
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
      print("❌ IMAGE PROVIDER ERROR: $e");
      return const AssetImage("assets/images/profile.jpg");
    }
  }

  void _showImagePickerSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        decoration: const BoxDecoration(
          color: Color(0xFF061B2B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
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
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
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
      print("🟦 PICK IMAGE START -> $source");

      final picker = ImagePicker();
      final xfile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (xfile == null) {
        print("🟨 PICK IMAGE CANCELLED");
        return;
      }

      final file = File(xfile.path);
      final bytes = await file.readAsBytes();
      final b64 = base64Encode(bytes);

      print("✅ PICKED IMAGE");
      print("➡️ path=${xfile.path}");
      print("➡️ bytes=${bytes.length}");
      print("➡️ b64Len=${b64.length}");

      setState(() {
        pickedImageFile = file;
        pickedImageBase64 = b64;
      });
    } catch (e) {
      print("❌ IMAGE PICK ERROR: $e");
      Get.snackbar(
        "Error",
        "Image pick failed: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _updateProfile() async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();

    print("🟦 UPDATE PROFILE CLICKED");
    print("➡️ name=$name");
    print("➡️ email=$email");
    print("➡️ pickedImageB64Len=${pickedImageBase64.length}");

    if (name.isEmpty) {
      Get.snackbar("Error", "Name is required", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar("Error", "Enter valid email", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final userId = session.userId.value;
    if (userId == 0) {
      Get.snackbar("Error", "Session user not found", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;

    try {
      print("🟦 CALLING EDIT PROFILE SERVICE...");
      final res = await EditProfileService.editProfile(
        userId: userId,
        name: name,
        imageBase64: pickedImageBase64, // "" allowed if not changed
      );
      print("✅ EDIT PROFILE RESPONSE: $res");

      // ✅ store new image if selected, else keep old
      final finalImageB64 =
      pickedImageBase64.isNotEmpty ? pickedImageBase64 : session.profileImageBase64.value;

      // ✅ update session so ProfileScreen shows updated info instantly
      session.createSessionFromUser({
        "id": userId,
        "name": name,
        "email": email,
        "level_id": session.levelId.value,
        "image": finalImageB64,
      });

      Get.snackbar("Success", "Profile updated", snackPosition: SnackPosition.BOTTOM);

      // ✅ instantly go back to ProfileScreen
      Get.back(result: true);
    } catch (e) {
      final msg = e.toString().replaceAll("Exception:", "").trim();
      print("❌ UPDATE PROFILE ERROR: $msg");
      Get.snackbar("Error", msg, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF061B2B);
    const cyan = Color(0xFF2CC7FF);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
          child: Column(
            children: [
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
                      color: Colors.white.withOpacity(0.08),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),

              GestureDetector(
                onTap: _showImagePickerSheet,
                child: Stack(
                  children: [
                    Container(
                      width: 118,
                      height: 118,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: cyan, width: 3),
                      ),
                      child: ClipOval(
                        child: Image(
                          image: _profileProvider(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: _showImagePickerSheet,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: cyan,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _InputField(controller: nameCtrl, hint: "Name"),
              const SizedBox(height: 14),
              _InputField(controller: emailCtrl, hint: "Email"),

              const SizedBox(height: 30),

              Obx(() {
                return AbsorbPointer(
                  absorbing: isLoading.value,
                  child: Opacity(
                    opacity: isLoading.value ? 0.6 : 1,
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
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/* ===================== INPUT FIELD ===================== */

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
  });

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white24),
        color: Colors.white.withOpacity(0.04),
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

/* ===================== BOTTOM SHEET TILE ===================== */

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2CC7FF).withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2CC7FF).withOpacity(0.35),
                ),
              ),
              child: Icon(icon, color: const Color(0xFF2CC7FF), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.white.withOpacity(0.65),
            ),
          ],
        ),
      ),
    );
  }
}
