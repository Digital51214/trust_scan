// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:lottie/lottie.dart';
//
// import 'package:social_saver/Authentication Screens/signin_screen.dart';
// import 'package:social_saver/session/session_controller.dart';
//
// import 'delete_account_screen.dart';
//
// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});
//
//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }
//
// class _SettingsScreenState extends State<SettingsScreen> {
//   static const bg = Color(0xFF061B2B);
//   static const cyan = Color(0xFF2CC7FF);
//   static const red = Color(0xFFFF3B3B);
//
//   bool notifOn = true;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent, // ✅ because bottom nav overlay
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // ✅ Background Gradient
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xFF0D5E7D),
//                   bg,
//                   Color(0xFF040F1D),
//                 ],
//               ),
//             ),
//           ),
//
//           SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 6),
//
//                   // ✅ Title
//                   const Text(
//                     "Settings",
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.w900,
//                       color: Colors.white,
//                     ),
//                   ),
//
//                   const SizedBox(height: 28),
//
//                   // ✅ Notifications Tile
//                   _PillTile(
//                     title: "Notifications",
//                     trailing: Transform.scale(
//                       scale: 0.95,
//                       child: Switch(
//                         value: notifOn,
//                         activeColor: cyan,
//                         activeTrackColor: cyan.withOpacity(.30),
//                         inactiveThumbColor: Colors.white70,
//                         inactiveTrackColor: Colors.white24,
//                         onChanged: (v) => setState(() => notifOn = v),
//                       ),
//                     ),
//                     onTap: () {},
//                   ),
//
//                   const SizedBox(height: 14),
//
//                   // ✅ Help Center Tile
//                   _PillTile(
//                     title: "Help Center",
//                     trailing: Icon(
//                       Icons.arrow_forward_ios_rounded,
//                       size: 18,
//                       color: Colors.white.withOpacity(.75),
//                     ),
//                     onTap: () {
//                       // TODO: open help center
//                     },
//                   ),
//
//                   const SizedBox(height: 14),
//
//                   // ✅ Delete Account Tile -> OPEN NEW SCREEN
//                   _PillTile(
//                     title: "Delete Account",
//                     trailing: Icon(
//                       Icons.arrow_forward_ios_rounded,
//                       size: 18,
//                       color: Colors.white.withOpacity(.75),
//                     ),
//                     onTap: () {
//                       Get.to(() => const DeleteAccountScreen());
//                     },
//                   ),
//
//                   const SizedBox(height: 22),
//
//                   // ✅ DELETE JSON BUTTON (dialog remains)
//                   SizedBox(
//                     width: double.infinity,
//                     height: 70,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(999),
//                       child: Material(
//                         color: Colors.transparent,
//                         child: InkWell(
//                           onTap: () => _deleteDialog(context),
//                           child: Center(
//                             child: Lottie.asset(
//                               "assets/images/Delete_Buttons.json",
//                               fit: BoxFit.contain,
//                               repeat: true,
//                               animate: true,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 14),
//
//                   // ✅ LOGOUT JSON BUTTON
//                   SizedBox(
//                     width: double.infinity,
//                     height: 70,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(999),
//                       child: Material(
//                         color: Colors.transparent,
//                         child: InkWell(
//                           onTap: () => _logoutDialog(context),
//                           child: Center(
//                             child: Lottie.asset(
//                               "assets/images/Log_Out.json",
//                               fit: BoxFit.contain,
//                               repeat: true,
//                               animate: true,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /* ===================== DIALOGS ===================== */
//
//   void _logoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierColor: Colors.black.withOpacity(0.65),
//       builder: (_) {
//         return _ThemedDialog(
//           title: "Logout",
//           message: "Are you sure you want to logout?",
//           icon: Icons.logout_rounded,
//           iconColor: cyan,
//           primaryText: "Yes",
//           primaryColor: cyan,
//           onPrimary: () {
//             Get.back(); // close dialog
//
//             // ✅ clear session
//             if (Get.isRegistered<SessionController>()) {
//               SessionController.instance.clearSession();
//             }
//
//             // ✅ go to SignIn (route)
//             Get.offAll(() => const SignInScreen());
//           },
//         );
//       },
//     );
//   }
//
//   void _deleteDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierColor: Colors.black.withOpacity(0.70),
//       builder: (_) {
//         return _ThemedDialog(
//           title: "Delete Account",
//           message:
//           "This action will permanently delete your account. Do you want to continue?",
//           icon: Icons.delete_forever_rounded,
//           iconColor: red,
//           primaryText: "Yes",
//           primaryColor: red,
//           onPrimary: () {
//             Get.back();
//
//             // TODO: delete account API
//             if (Get.isRegistered<SessionController>()) {
//               SessionController.instance.clearSession();
//             }
//             Get.offAll(() => const SignInScreen());
//           },
//         );
//       },
//     );
//   }
// }
//
// /* ===================== Pill Tile ===================== */
//
// class _PillTile extends StatelessWidget {
//   const _PillTile({
//     required this.title,
//     required this.trailing,
//     required this.onTap,
//   });
//
//   final String title;
//   final Widget trailing;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(28),
//       onTap: onTap,
//       child: Container(
//         height: 56,
//         padding: const EdgeInsets.symmetric(horizontal: 18),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(28),
//           border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
//         ),
//         child: Row(
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 15.5,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//               ),
//             ),
//             const Spacer(),
//             trailing,
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /* ===================== Themed Dialog ===================== */
//
// class _ThemedDialog extends StatelessWidget {
//   const _ThemedDialog({
//     required this.title,
//     required this.message,
//     required this.icon,
//     required this.iconColor,
//     required this.primaryText,
//     required this.primaryColor,
//     required this.onPrimary,
//   });
//
//   final String title;
//   final String message;
//   final IconData icon;
//   final Color iconColor;
//
//   final String primaryText;
//   final Color primaryColor;
//   final VoidCallback onPrimary;
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: const EdgeInsets.symmetric(horizontal: 22),
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
//         decoration: BoxDecoration(
//           color: const Color(0xFF0A2235),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: primaryColor.withOpacity(.35),
//             width: 1.2,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.40),
//               blurRadius: 18,
//               offset: const Offset(0, 12),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 54,
//               height: 54,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: primaryColor.withOpacity(0.12),
//                 border: Border.all(color: primaryColor.withOpacity(.40)),
//               ),
//               child: Icon(icon, color: iconColor, size: 28),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w900,
//                 color: Colors.white,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               message,
//               style: TextStyle(
//                 fontSize: 13.2,
//                 height: 1.45,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white.withOpacity(.70),
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     style: OutlinedButton.styleFrom(
//                       shape: const StadiumBorder(),
//                       side: BorderSide(
//                         color: Colors.white.withOpacity(.18),
//                         width: 1,
//                       ),
//                       foregroundColor: Colors.white70,
//                       padding: const EdgeInsets.symmetric(vertical: 13),
//                     ),
//                     onPressed: () => Get.back(),
//                     child: const Text(
//                       "No",
//                       style: TextStyle(
//                         fontWeight: FontWeight.w800,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryColor,
//                       shape: const StadiumBorder(),
//                       elevation: 0,
//                       padding: const EdgeInsets.symmetric(vertical: 13),
//                     ),
//                     onPressed: onPrimary,
//                     child: Text(
//                       primaryText,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w900,
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:social_saver/Authentication Screens/signin_screen.dart';
import 'package:social_saver/session/session_controller.dart';
import 'delete_account_screen.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          /// 🌌 Animated Gradient Background
          AnimatedContainer(
            duration: const Duration(seconds: 6),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF001F3F),
                  Color(0xFF00E5FF),
                  Color(0xFF020C18),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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

                  /// 🔵 Title
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

                  /// 🔔 Notifications
                  _PillTile(
                    title: "Notifications",
                    trailing: Switch(
                      value: notifOn,
                      activeColor: cyan,
                      onChanged: (v) => setState(() => notifOn = v),
                    ),
                    onTap: () {},
                  ),

                  const SizedBox(height: 14),

                  /// ❓ Help
                  _PillTile(
                    title: "Help Center",
                    trailing: Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withOpacity(.7), size: 18),
                    onTap: () {},
                  ),

                  const SizedBox(height: 14),

                  /// 🗑 Delete Account Screen
                  _PillTile(
                    title: "Delete Account",
                    trailing: Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withOpacity(.7), size: 18),
                    onTap: () {
                      Get.to(() => const DeleteAccountScreen());
                    },
                  ),

                  const SizedBox(height: 30),

                  /// 🔴 DELETE BUTTON (AI Pulse)
                  _pulseButton(
                    child: Lottie.asset("assets/images/Delete_Buttons.json"),
                    onTap: () => _deleteDialog(context),
                  ),

                  const SizedBox(height: 16),

                  /// 🔵 LOGOUT BUTTON (AI Pulse)
                  _pulseButton(
                    child: Lottie.asset("assets/images/Log_Out.json"),
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

  /// 🤖 AI Pulse Animation
  Widget _pulseButton({required Widget child, required VoidCallback onTap}) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.95, end: 1.05),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, value, childWidget) {
        return Transform.scale(
          scale: value as double,
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
                color: cyan.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 1,
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  /* ===================== DIALOGS ===================== */

  void _logoutDialog(BuildContext context) {
    showDialog(
      context: context,
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
              border: Border.all(color: cyan.withOpacity(.3)),
              boxShadow: [
                BoxShadow(
                  color: cyan.withOpacity(.3),
                  blurRadius: 12,
                )
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
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 40),
                const SizedBox(height: 10),
                Text(title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text(message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70)),
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
                            backgroundColor: primaryColor),
                        onPressed: onPrimary,
                        child: Text(primaryText),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}